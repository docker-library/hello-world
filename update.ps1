$ErrorActionPreference = "Stop";
docker build -f .\windows\Dockerfile.build -t builder .\windows\.
docker create --name out builder
docker cp out:hello.exe .\windows\.
docker rm out
docker build -t hello-world:windows .\windows\.
Remove-Item -Force .\windows\hello.exe
docker run hello-world:windows
