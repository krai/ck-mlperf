See documentation at https://github.com/mlcommons/power-dev/tree/master/ptd_client_server.

# Usage

```
ck run \
    --env.CK_MLPERF_POWER_CLIENT_ADDRESS=192.168.1.2 \
    --env.CK_MLPERF_POWER_CLIENT_LOADGEN_LOGS='
        mkdir $CK_MLPERF_POWER_CLIENT_LOADGEN_LOGS
        touch $CK_MLPERF_POWER_CLIENT_LOADGEN_LOGS/loadgen_summary.txt
    ' \
    --env.CK_MLPERF_POWER_CLIENT_LOADGEN_LOGS=$PWD/откуда_брать_результаты \
    ck-mlperf:program:mlperf-power-client
```


ck benchmark \
	--env.CK_MLPERF_POWER_CLIENT_ADDRESS=127.1 \
	--env.CK_MLPERF_POWER_CLIENT_LOADGEN_LOGS=$PWD/woof \
	--env.CK_MLPERF_POWER_CLIENT_WORKLOAD='
		mkdir $CK_MLPERF_POWER_CLIENT_LOADGEN_LOGS
		touch $CK_MLPERF_POWER_CLIENT_LOADGEN_LOGS/test123
	' \
	--record --record_repo=local --repetitions=1 \
	--record_uoa=mlperf-power-client-test \
	ck-mlperf:program:mlperf-power-client

* `CK_MLPERF_POWER_CLIENT_ADDRESS`: `--addr`, server address
* `CK_MLPERF_POWER_CLIENT_LOADGEN_LOGS`: `--loadgen-logs`, where to get the results
* `CK_MLPERF_POWER_CLIENT_WORKLOAD`: `--run-workload`. This script is expected to put its output into `$CK_MLPERF_POWER_CLIENT_LOADGEN_LOGS`.

Warning: directory specified in `CK_MLPERF_POWER_CLIENT_LOADGEN_LOGS` will be removed during the run!
