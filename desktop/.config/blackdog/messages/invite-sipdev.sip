INVITE sip:+13125556363@sipdev.telnyx.com SIP/2.0
Via: SIP/2.0/UDP 127.0.0.1:5060;branch=z9hG4bK-blackdog-invite
Max-Forwards: 70
Contact: <sip:blackdog@127.0.0.1:5060>
To: <sip:+13125556363@sipdev.telnyx.com>
From: <sip:blackdog@sipdev.telnyx.com>;tag=blackdog-invite
Call-ID: blackdog-invite
CSeq: 1 INVITE
Allow: INVITE, ACK, CANCEL, BYE, OPTIONS
Content-Type: application/sdp
Supported: replaces, timer
User-Agent: blackdog-shoot
Content-Length: 129

v=0
o=blackdog 0 0 IN IP4 127.0.0.1
s=blackdog
c=IN IP4 127.0.0.1
t=0 0
m=audio 28000 RTP/AVP 0
a=sendrecv
