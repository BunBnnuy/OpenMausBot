#!/usr/bin/env bash
# Bench wrapper: samples the machine while the command runs, then prints one BENCH line. Never merged.
set +e
name="$1"; shift
log="$RUNNER_TEMP/$name.vmstat"
vmstat -n 5 > "$log" &
vm=$!
start=$(date +%s)
"$@"
code=$?
end=$(date +%s)
kill $vm 2>/dev/null
awk -v name="$name" -v secs=$((end-start)) -v code=$code 'NR>2 { n++; idle+=$15; wa+=$16; us+=$13; sy+=$14; r+=$1; if (min==""||$4+$6<min) min=$4+$6 } END { printf "BENCH name=%s seconds=%d exit=%d cpu_user=%.0f%% cpu_sys=%.0f%% cpu_wait=%.0f%% cpu_idle=%.0f%% runq=%.1f min_free_mb=%d samples=%d\n", name, secs, code, us/n, sy/n, wa/n, idle/n, r/n, min/1024, n }' "$log"
if [ -n "${OMB_VITEST_RETRY_LOG:-}" ] && [ -f "$OMB_VITEST_RETRY_LOG" ]; then echo "BENCH retries=$(wc -l < "$OMB_VITEST_RETRY_LOG")"; cat "$OMB_VITEST_RETRY_LOG" | cut -c1-200; fi
exit 0
