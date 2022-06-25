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
	scp 0_Schema.sql ${HOST1}:~/isuumo/webapp/mysql/db/0_Schema.sql
	scp 3_Schema.sql ${HOST1}:~/isuumo/webapp/mysql/db/3_Schema.sql
	cat host1-isuumo.go.service | ssh ${HOST1} sudo tee /etc/systemd/system/isuumo.go.service >/dev/null
	ssh ${HOST1} sudo systemctl daemon-reload
	ssh ${HOST1} sudo systemctl start isuumo.go

deploy2:
	go build -o isuumo
	ssh ${HOST2} sudo systemctl stop isuumo.go
	scp isuumo ${HOST2}:~/isuumo/webapp/go/isuumo
	scp env.sh ${HOST2}:~/isuumo/webapp/mysql/db/0_Schema.sql
	scp 0_Schema.sql ${HOST2}:~/isuumo/webapp/mysql/db/0_Schema.sql
	scp 3_Schema.sql ${HOST2}:~/isuumo/webapp/mysql/db/3_Schema.sql
	cat host1-isuumo.go.service | ssh ${HOST2} sudo tee /etc/systemd/system/isuumo.go.service >/dev/null
	ssh ${HOST2} sudo systemctl daemon-reload
	ssh ${HOST2} sudo systemctl start isuumo.go

deploy-all-all:
	@make deploy-1-all
	@make deploy-2-all
	@make deploy-3-all

deploy-1-all:
	@make deploy-1-web
	@make deploy-1-db
	@make deploy-1-app

deploy-2-all:
	@make deploy-2-web
	@make deploy-2-db
	@make deploy-2-app

deploy-3-all:
	@make deploy-3-web
	@make deploy-3-db
	@make deploy-3-app

deploy-1-app:
	go build -o isuumo
	ssh ${HOST1} sudo systemctl stop isuumo.go
	scp isuumo ${HOST1}:~/isuumo/webapp/go/isuumo
	scp env.sh ${HOST1}:~/env.sh
	cat host1-isuumo.go.service | ssh ${HOST1} sudo tee /etc/systemd/system/isuumo.go.service >/dev/null
	ssh ${HOST1} sudo systemctl daemon-reload
	ssh ${HOST1} sudo systemctl start isuumo.go

deploy-2-app:
	go build -o isuumo
	ssh ${HOST2} sudo systemctl stop isuumo.go
	scp isuumo ${HOST2}:~/isuumo/webapp/go/isuumo
	scp env.sh ${HOST2}:~/env.sh
	cat host2-isuumo.go.service | ssh ${HOST2} sudo tee /etc/systemd/system/isuumo.go.service >/dev/null
	ssh ${HOST2} sudo systemctl daemon-reload
	ssh ${HOST2} sudo systemctl start isuumo.go

deploy-3-app:
	go build -o isuumo
	ssh ${HOST3} sudo systemctl stop isuumo.go
	scp isuumo ${HOST3}:~/isuumo/webapp/go/isuumo
	scp env.sh ${HOST3}:~/env.sh
	cat host3-isuumo.go.service | ssh ${HOST3} sudo tee /etc/systemd/system/isuumo.go.service >/dev/null
	ssh ${HOST3} sudo systemctl daemon-reload
	ssh ${HOST3} sudo systemctl start isuumo.go

deploy-1-web:
	cat host1-nginx.conf | ssh ${HOST1} sudo tee /etc/nginx/nginx.conf >/dev/null
	cat host1-isuumo.conf | ssh ${HOST1} sudo tee /etc/nginx/sites-available/isuumo.conf >/dev/null
	ssh ${HOST1} sudo nginx -t
	ssh ${HOST1} sudo systemctl restart nginx

deploy-2-web:
	cat host2-nginx.conf | ssh ${HOST2} sudo tee /etc/nginx/nginx.conf >/dev/null
	cat host2-isuumo.conf | ssh ${HOST2} sudo tee /etc/nginx/sites-available/isuumo.conf >/dev/null
	ssh ${HOST2} sudo nginx -t
	ssh ${HOST2} sudo systemctl restart nginx

deploy-3-web:
	cat host3-nginx.conf | ssh ${HOST3} sudo tee /etc/nginx/nginx.conf >/dev/null
	cat host3-isuumo.conf | ssh ${HOST3} sudo tee /etc/nginx/sites-available/isuumo.conf >/dev/null
	ssh ${HOST3} sudo nginx -t
	ssh ${HOST3} sudo systemctl restart nginx

deploy-1-db:
	cat host3-mysqld.cnf | ssh ${HOST1} sudo tee /etc/mysql/mysql.conf.d/mysqld.cnf>/dev/null
	cat host3-mysql.service | ssh ${HOST1} sudo tee /lib/systemd/system/mysql.service>/dev/null
	ssh ${HOST1} sudo systemctl daemon-reload
	ssh ${HOST1} sudo systemctl restart mysql

deploy-2-db:
	cat host3-mysqld.cnf | ssh ${HOST2} sudo tee /etc/mysql/mysql.conf.d/mysqld.cnf>/dev/null
	cat host3-mysql.service | ssh ${HOST2} sudo tee /lib/systemd/system/mysql.service>/dev/null
	ssh ${HOST2} sudo systemctl daemon-reload
	ssh ${HOST2} sudo systemctl restart mysql

deploy-3-db:
	cat host3-mysqld.cnf | ssh ${HOST3} sudo tee /etc/mysql/mysql.conf.d/mysqld.cnf>/dev/null
	cat host3-mysql.service | ssh ${HOST3} sudo tee /lib/systemd/system/mysql.service>/dev/null
	ssh ${HOST3} sudo systemctl daemon-reload
	ssh ${HOST3} sudo systemctl restart mysql

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

collect-logs2:
	mkdir -p logs/${TIMEID}
	rm -f logs/latest
	ln -sf ${TIMEID} logs/latest
	scp ${HOST2}:/tmp/cpu.pprof logs/latest/cpu-web1.pprof
	ssh ${HOST2} sudo chmod 644 /var/log/nginx/access.log
	scp ${HOST2}:/var/log/nginx/access.log logs/latest/access-web1.log
	scp ${HOST2}:/tmp/sql.log logs/latest/sql-web1.log
	ssh ${HOST2} sudo truncate -c -s 0 /var/log/nginx/access.log
	ssh ${HOST2} sudo truncate -c -s 0 /tmp/sql.log

truncate-logs:
	ssh ${HOST1} sudo truncate -c -s 0 /var/log/nginx/access.log
	ssh ${HOST1} sudo truncate -c -s 0 /tmp/sql.log

truncate-logs2:
	ssh ${HOST2} sudo truncate -c -s 0 /var/log/nginx/access.log
	ssh ${HOST2} sudo truncate -c -s 0 /tmp/sql.log

discord:
	curl -H "Content-Type: application/json" -X POST -d '{"username": "bench", "content": "bench"}'