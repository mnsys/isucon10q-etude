HOST0=isucon@35.77.73.48
HOST1=isucon@18.176.52.57
HOST2=isucon@54.95.29.70
HOST3=isucon@54.95.53.252

TIMEID := $(shell date +%Y%m%d-%H%M%S)

# https://github.com/hirosuzuki/perf-logs-viewer
# https://github.com/hirosuzuki/go-sql-logger

build:
	go build -o isuumo

deploy:
	go build -o isuumo
	ssh ${HOST1} sudo systemctl stop isuumo.go
	scp isuumo ${HOST1}:~/isuumo/webapp/go/isuumo
	scp env.sh ${HOST1}:~/env.sh
	cat host1-isuumo.go.service | ssh ${HOST1} sudo tee /etc/systemd/system/isuumo.go.service >/dev/null
	ssh ${HOST1} sudo systemctl daemon-reload
	ssh ${HOST1} sudo systemctl start isuumo.go

deploy-nginx:
	cat host1-nginx.conf | ssh ${HOST1} sudo tee /etc/nginx/nginx.conf >/dev/null
	ssh ${HOST1} sudo nginx -t
	ssh ${HOST1} sudo systemctl restart nginx

host0:
	ssh ${HOST0}

host1:
	ssh ${HOST1}

host2:
	ssh ${HOST2}

host3:
	ssh -L 13306:127.0.0.1:3306 ${HOST3}
	# mysql -h 127.0.0.1 -P 13306 -uisucon -pisucon isucondition

fetch-conf:
	mkdir -p files
	scp ${HOST1}:/etc/systemd/system/isuumo.go.service files
	scp ${HOST1}:/etc/nginx/nginx.conf files
	scp ${HOST1}:/etc/mysql/my.cnf files


perf-logs-viewer:
	# go install https://github.com/hirosuzuki/perf-logs-viewer:latest
	perf-logs-viewer

pprof:
	go tool pprof -http="127.0.0.1:8081" logs/latest/cpu-web1.pprof 

collect-logs:
	mkdir -p logs/${TIMEID}
	rm -f logs/latest
	ln -sf ${TIMEID} logs/latest
	scp ${HOST1}:/tmp/cpu.pprof logs/latest/cpu-web1.pprof
	ssh ${HOST1} sudo chmod 644 /var/log/nginx/access.log
	scp ${HOST1}:/var/log/nginx/access.log logs/latest/access-web1.log
	scp ${HOST1}:/tmp/sql.log logs/latest/sql-web1.log
	ssh ${HOST1} sudo truncate -c -s 0 /var/log/nginx/access.log
	ssh ${HOST1} sudo truncate -c -s 0 /tmp/sql.log

truncate-logs:
	ssh ${HOST1} sudo truncate -c -s 0 /var/log/nginx/access.log
	ssh ${HOST1} sudo truncate -c -s 0 /tmp/sql.log
