#include <sys/syscall.h>
#include <unistd.h>

#ifndef DOCKER_IMAGE
	#define DOCKER_IMAGE "my-hello-world"
#endif

#ifndef DOCKER_GREETING
	#define DOCKER_GREETING "Dockerから、こんにちは！!"
#endif

#ifndef DOCKER_ARCH
	#define DOCKER_ARCH "amd64"
#endif

const char message[] =
	"\n"
	DOCKER_GREETING "\n"
	"このメッセージが表示されていれば、インストールは正常終了しました。\n"
	"\n"
	"メッセージを表示するために、Dockerは以下の手順を処理しました：\n"
	" 1. DockerクライアントはDockerデーモンに接続。\n"
	" 2. DockerデーモンはDocker Hubから\"" DOCKER_IMAGE "\" イメージをダウンロード。\n"
	"    (" DOCKER_ARCH ")\n"
	" 3. Dockerデーモンはダウンロードしたイメージから、実行可能な新しいコンテナを作成し、\n"
	"    今あなたが読んでいるこのメッセージを表示します。\n"
	" 4. Dockerデーモンは出力結果をDockerクライアントに流し、あなたのターミナルに出力します。\n"
	"\n"
	"さらにチャレンジするには、Ubuntu コンテナを次のコマンドで動かしましょう：\n"
	" $ docker run -it ubuntu bash\n"
	"\n"
	"イメージの共有、自動ワークフローなどの機能は、フリーなDocker IDで行えます：\n"
	" https://hub.docker.com/\n"
	"\n"
	"更なる例や考え方は、ドキュメントをご覧ください：\n"
	" https://docs.docker.com/get-started/\n"
	"\n";

int main() {
	//write(1, message, sizeof(message) - 1);
	syscall(SYS_write, STDOUT_FILENO, message, sizeof(message) - 1);

	//_exit(0);
	//syscall(SYS_exit, 0);
	return 0;
}
