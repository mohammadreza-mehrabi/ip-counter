#!/usr/bin/env bats
# ============================================
# test_ip_counter.bats — Unit tests
# ============================================

setup() {
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    IP_COUNTER="${PROJECT_ROOT}/bin/ip_counter.sh"
    TEST_LOG="${BATS_TMPDIR}/test_ssh.log"
    TEST_OUTPUT="${BATS_TMPDIR}/test_output.txt"
    rm -f "$TEST_LOG" "$TEST_OUTPUT"
}

teardown() {
    rm -f "$TEST_LOG" "$TEST_OUTPUT"
}

create_test_log() {
    cat > "$TEST_LOG" << 'EOF'
Oct 10 08:15:23 sshd[1234]: Failed password for root from 192.168.1.10 port 54321 ssh2
Oct 10 08:15:24 sshd[1235]: Failed password for admin from 10.0.0.5 port 54322 ssh2
Oct 10 08:15:25 sshd[1236]: Failed password for root from 192.168.1.10 port 54323 ssh2
Oct 10 08:15:26 sshd[1237]: Accepted password for user from 172.16.1.20 port 54324 ssh2
Oct 10 08:15:27 sshd[1238]: Failed password for root from 192.168.1.10 port 54325 ssh2
EOF
}

@test "displays help with -h" {
    run "$IP_COUNTER" -h
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "displays help with --help" {
    run "$IP_COUNTER" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "fails without arguments" {
    run "$IP_COUNTER"
    [ "$status" -ne 0 ]
    [[ "$output" =~ "No log file" ]]
}

@test "fails with nonexistent file" {
    run "$IP_COUNTER" /tmp/does_not_exist.log
    [ "$status" -ne 0 ]
}

@test "fails with unknown option" {
    create_test_log
    run "$IP_COUNTER" "$TEST_LOG" -x
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Unknown option" ]]
}

@test "detects IPs with failed attempts" {
    create_test_log
    run "$IP_COUNTER" "$TEST_LOG"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "192.168.1.10" ]]
    [[ "$output" =~ "10.0.0.5" ]]
    [[ "$output" =~ "root" ]]
}

@test "counts failed attempts correctly" {
    create_test_log
    run "$IP_COUNTER" "$TEST_LOG"
    [[ "$output" =~ "192.168.1.10" ]]
    [[ "$output" =~ "3 attempts" ]]
}

@test "ignores successful logins" {
    create_test_log
    run "$IP_COUNTER" "$TEST_LOG"
    [[ ! "$output" =~ "172.16.1.20" ]]
}

@test "respects threshold option" {
    create_test_log
    run "$IP_COUNTER" "$TEST_LOG" -t 2
    [ "$status" -eq 1 ]
    [[ "$output" =~ "192.168.1.10" ]]
    [[ ! "$output" =~ "10.0.0.5" ]]
}

@test "returns 0 when no threats found" {
    create_test_log
    run "$IP_COUNTER" "$TEST_LOG" -t 100
    [ "$status" -eq 0 ]
}

@test "saves output to file with -o" {
    create_test_log
    run "$IP_COUNTER" "$TEST_LOG" -o "$TEST_OUTPUT"
    [ -f "$TEST_OUTPUT" ]
    grep -q "192.168.1.10" "$TEST_OUTPUT"
}

@test "respects top N option" {
    create_test_log
    run "$IP_COUNTER" "$TEST_LOG" -n 1
    [[ "$output" =~ "192.168.1.10" ]]
    [[ ! "$output" =~ "10.0.0.5" ]]
}

@test "ignores invalid IPs" {
    cat > "$TEST_LOG" << 'EOF'
Oct 10 08:15:23 sshd[1234]: Failed password for root from 999.999.999.999 port 54321 ssh2
Oct 10 08:15:24 sshd[1235]: Failed password for admin from 192.168.1.10 port 54322 ssh2
EOF
    run "$IP_COUNTER" "$TEST_LOG"
    [[ "$output" =~ "192.168.1.10" ]]
    [[ ! "$output" =~ "999.999.999.999" ]]
}

@test "handles empty log file" {
    touch "$TEST_LOG"
    run "$IP_COUNTER" "$TEST_LOG"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "No failed attempts" ]]
}
