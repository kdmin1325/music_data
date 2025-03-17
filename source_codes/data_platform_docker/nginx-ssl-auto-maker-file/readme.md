# 해당 블로그 참조
https://node-js.tistory.com/32

# 절차
1. No-Ip (무료 도메인 받기)
2. data/nginx/app.conf 파일 수정
3. init-letsencrypt.sh 파일 수정
4. docker-compose 실행
5. 다음 명렁어 실행
```shell
chmod +x init-letsencrypt.sh
sudo ./init-letsencrypt.sh
```
6. https 적용을 위한 -> nginx.conf 수정하기
7. docker-compose 파일 수정하기

```shell
version: '3'

services:
  nginx:
    image: nginx:1.15-alpine
    restart: unless-stopped
    volumes:
      - ./data/nginx:/etc/nginx/conf.d
      - ./data/certbot/conf:/etc/letsencrypt
      - ./data/certbot/www:/var/www/certbot
    ports:
      - "80:80"
      - "443:443"
    command: "/bin/sh -c 'while :; do sleep 6h & wait $${!}; nginx -s reload; done & nginx -g \\"daemon off;\\"'"
  certbot:
    image: certbot/certbot
    restart: unless-stopped
    volumes:
      - ./data/certbot/conf:/etc/letsencrypt
      - ./data/certbot/www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"
```


1. 반드시 엔진엑스를 실행시킨 상태에서 init-~.sh 파일 실행시킬 것.


- 엔진엑스 - ssl 연동 단계

1. docker-compose.yml 파일을 다음 명령어를 통해 실행시킨다.

```python
docker-compose up
```

2. data/nginx/app.conf속 도메인 주소를 전부 수정해준다.
3. init-letsencrypt.sh 속 도메인 주소와, 이메일 주소를 설정해준다.
4. 추 후에 app.conf 에  443 관련 서버 정보를 수정한다 -> 프록시 서버 설정.

서버 실행시킬 때 -> docker-compose up으로 간편하게 실행가능.

