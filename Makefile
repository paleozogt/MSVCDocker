
msvc12: Dockerfile
	docker build -f Dockerfile -t msvc:12 --build-arg MSVC=12 .

msvc14: Dockerfile
	docker build -f Dockerfile -t msvc:14 --build-arg MSVC=14 .

msvc15: Dockerfile
	docker build -f Dockerfile -t msvc:15 --build-arg MSVC=15 .
