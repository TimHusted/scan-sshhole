# CVE-2026-123158 - SSHHole

Below is references to this issue and a lot of the remediation steps involve you getting inside vulnerable systems, but you have to know what is actually vulnerable.  Since some of this can be embedded systems, or containers that you did not build, a way to scan for this is needed.

This vulnerability allows a network connection via OpenSSH when certain conditions exist, and without a valid password.  Here is the TL;DR from IONIX.IO

CVE-2026-123158 (CVSS 3.1 8.1, High) is a password authentication bypass in sshd on Linux systems that use musl libc without PAM, most notably Alpine Linux. It is fixed in OpenSSH 10.6p2 (November 5, 2026) and in patched Alpine packages on every supported branch.

Against an account with no password set, any password between 256 and 1024 characters is accepted. Alpine’s default openssh-server package is affected in its default configuration, and public reproduction labs already exist.

Not affected: glibc distributions (Debian, Ubuntu, RHEL and derivatives) and sshd running with PAM enabled.

What to do now: upgrade OpenSSH (on Alpine: apk upgrade -U -a) and restart sshd. If you can’t upgrade yet, set PasswordAuthentication no and restart sshd.

Here is their full post: https://www.ionix.io/blog/sshhole-cve-2026-123158-and-how-ionix-is-helping-you-respond/

A vulnerable instance can be found at: https://github.com/leonjza/sshhole-lab

I recommend spinning up this container to aim the below scripts at to verify you have a working scanner.

**THIS IS FOR YOUR INTERNAL USAGE ONLY.**

To automate scanning, you will need a list of targets in SERVERS.TXT and you can specify IPv4:PORT or it will default to :22.  You can use resolvable names but why risk a DNS lookup?

You will need a list of users in USERS.TXT - for the most part, root and alpine.

The system uses SSH and expect, I originally wrote it to use sshpass but found that passing the password through the PTTY causes issues with dropped chars leading to failures, the expect script seems to solve this issue.

You will need the ssh_test.exp and you will need to run the scan-sshhole.sh.  
Here is the expected output when running the vulnerable test server on localhost port 2222:
        
`Test Password:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
==================================================
🌐 Target Server: 127.0.0.1 (Port: 2222)
==================================================
Testing credentials for user [root]...
--------------------------------------------------
Testing credentials for user [alpine]...
  ✅ VULNERABLE: [alpine] to [127.0.0.1] - REMEDIATE.
--------------------------------------------------
`