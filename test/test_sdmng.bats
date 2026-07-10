#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"

  cat > "$TEST_DIR/mock_sdm" <<SCRIPT
#!/usr/bin/env bash
echo "\$@" >> "$TEST_DIR/sdm_calls.log"
case "\$1" in
  status) exit 0 ;;
  login) exit 0 ;;
  ssh)
    if [[ "\$2" == "config" ]]; then
      cp "$TEST_DIR/sdm_ssh_config_source" "$TEST_DIR/.sdm/ssh_config"
    fi
    ;;
  access) exit 0 ;;
esac
SCRIPT
  chmod +x "$TEST_DIR/mock_sdm"

  mkdir -p "$TEST_DIR/.sdm"

  cat > "$TEST_DIR/sdm_ssh_config_source" <<'EOF'
Host tel-ch1-ibm-prod-371 tel-ch1-ibm-prod-371.hosts.telnyx.io
        HostName 127.0.0.1
        Port     10786

Host tel-at1-prox-dev-224 tel-at1-prox-dev-224.hosts.telnyx.io
        HostName 127.0.0.1
        Port     10197
EOF
  cp "$TEST_DIR/sdm_ssh_config_source" "$TEST_DIR/.sdm/ssh_config"

  cat > "$TEST_DIR/work_config" <<'EOF'
Host p371 us6
  HostName tel-ch1-ibm-prod-371.ipa.corp.telnyx.com
  IdentityFile ~/.ssh/telnyx_id_rsa

Host d224
  HostName tel-at1-prox-dev-224.ipa.corp.telnyx.com
  IdentityFile ~/.ssh/telnyx_id_rsa

Host ec2
  HostName 3.91.102.66
  User ubuntu

Host short-name
  HostName hn
  User root

Host p999 missing-server
  HostName tel-xx1-ibm-prod-999.ipa.corp.telnyx.com
  IdentityFile ~/.ssh/telnyx_id_rsa

Host commented-out
  # HostName should-be-ignored.example.com
  IdentityFile ~/.ssh/telnyx_id_rsa
EOF

  export HOME="$TEST_DIR/fakehome"
  mkdir -p "$HOME/.ssh/config.d"

  export TEST_DIR
  export SDM_BIN="$TEST_DIR/mock_sdm"
  export SDM_EMAIL="test@example.com"
  export SDM_SSH_CONFIG="$TEST_DIR/.sdm/ssh_config"
  export WORK_SSH_CONFIG="$TEST_DIR/work_config"

  cp "$(dirname "$BATS_TEST_FILENAME")/../desktop/bin/sdmng" "$TEST_DIR/sdmng"
  chmod +x "$TEST_DIR/sdmng"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "ensures login when sdm status fails" {
  cat > "$TEST_DIR/mock_sdm" <<SCRIPT
#!/usr/bin/env bash
echo "\$@" >> "$TEST_DIR/sdm_calls.log"
case "\$1" in
  status) exit 1 ;;
  login) exit 0 ;;
  ssh) cp "$TEST_DIR/sdm_ssh_config_source" "$TEST_DIR/.sdm/ssh_config" ;;
  access) exit 0 ;;
esac
SCRIPT
  chmod +x "$TEST_DIR/mock_sdm"

  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  grep -q "login --email test@example.com" "$TEST_DIR/sdm_calls.log"
}

@test "unlocks macOS keychain before login when OSTYPE is darwin" {
  cat > "$TEST_DIR/mock_sdm" <<SCRIPT
#!/usr/bin/env bash
echo "sdm:\$@" >> "$TEST_DIR/calls.log"
case "\$1" in
  status) exit 1 ;;
  login) exit 0 ;;
  ssh) cp "$TEST_DIR/sdm_ssh_config_source" "$TEST_DIR/.sdm/ssh_config" ;;
  access) exit 0 ;;
esac
SCRIPT
  chmod +x "$TEST_DIR/mock_sdm"

  cat > "$TEST_DIR/security" <<SCRIPT
#!/usr/bin/env bash
echo "security:\$@" >> "$TEST_DIR/calls.log"
exit 0
SCRIPT
  chmod +x "$TEST_DIR/security"
  mkdir -p "$HOME/Library/Keychains"
  touch "$HOME/Library/Keychains/login.keychain-db"

  run env OSTYPE=darwin22 PATH="$TEST_DIR:$PATH" "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  grep -q "security:unlock-keychain $HOME/Library/Keychains/login.keychain-db" "$TEST_DIR/calls.log"
  grep -q "sdm:login --email test@example.com" "$TEST_DIR/calls.log"
}

@test "does not unlock macOS keychain when disabled" {
  cat > "$TEST_DIR/mock_sdm" <<SCRIPT
#!/usr/bin/env bash
echo "sdm:\$@" >> "$TEST_DIR/calls.log"
case "\$1" in
  status) exit 1 ;;
  login) exit 0 ;;
  ssh) cp "$TEST_DIR/sdm_ssh_config_source" "$TEST_DIR/.sdm/ssh_config" ;;
  access) exit 0 ;;
esac
SCRIPT
  chmod +x "$TEST_DIR/mock_sdm"

  cat > "$TEST_DIR/security" <<SCRIPT
#!/usr/bin/env bash
echo "security:\$@" >> "$TEST_DIR/calls.log"
exit 0
SCRIPT
  chmod +x "$TEST_DIR/security"
  mkdir -p "$HOME/Library/Keychains"
  touch "$HOME/Library/Keychains/login.keychain-db"

  run env OSTYPE=darwin22 SDM_MACOS_UNLOCK_KEYCHAIN=0 PATH="$TEST_DIR:$PATH" "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  ! grep -q "security:" "$TEST_DIR/calls.log"
}

@test "skips login when already authenticated" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  ! grep -q "login" "$TEST_DIR/sdm_calls.log"
}

@test "refreshes sdm ssh config" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  grep -q "ssh config" "$TEST_DIR/sdm_calls.log"
}

@test "copies sdm ssh_config to ~/.ssh/config.d/sdm" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  [[ -f "$HOME/.ssh/config.d/sdm" ]]
}

@test "adds short aliases to sdm copy (prod -> pNNN)" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  grep -q "^Host p371 tel-ch1-ibm-prod-371" "$HOME/.ssh/config.d/sdm"
}

@test "adds short aliases to sdm copy (dev -> dNNN)" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  grep -q "^Host d224 tel-at1-prox-dev-224" "$HOME/.ssh/config.d/sdm"
}

@test "preserves non-Host lines in sdm copy" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  grep -q "Port     10786" "$HOME/.ssh/config.d/sdm"
}

@test "requests access for hosts missing from SDM" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  grep -q "access to tel-xx1-ibm-prod-999 --reason ENGDESK-50816 --duration 30d" "$TEST_DIR/sdm_calls.log"
}

@test "does not request access for hosts already in SDM" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  ! grep -q "access to tel-ch1-ibm-prod-371" "$TEST_DIR/sdm_calls.log"
  ! grep -q "access to tel-at1-prox-dev-224" "$TEST_DIR/sdm_calls.log"
}

@test "requests access for non-telnyx hosts too" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  grep -q "access to 3 " "$TEST_DIR/sdm_calls.log"
}

@test "does not treat bare hostname keys as shell variables under nounset" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  grep -q "access to hn " "$TEST_DIR/sdm_calls.log"
}

@test "ignores commented HostName lines" {
  run "$TEST_DIR/sdmng"
  [ "$status" -eq 0 ]
  ! grep -q "access to should-be-ignored" "$TEST_DIR/sdm_calls.log"
}
