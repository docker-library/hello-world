docker build -f .\windows\Dockerfile.build -t builder .\windows\.
docker create --name out builder
docker cp out:hello.exe .\windows\.
docker rm out
docker build -t hello-world:windows .\windows\.
docker run hello-world:windows
