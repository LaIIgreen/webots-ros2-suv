# Webots ROS 2 SUV

Симуляция Газели в Webots и ROS 2 Humble. После клонирования скрипт собирает Docker-образ на вашем компьютере и поднимает контейнер. Внутри контейнера можно запускать любые команды ROS; основной запуск симуляции — `robot_launch.py`.

## Что нужно на компьютере

- Linux с Docker
- для GPU: [nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

```sh
sudo apt install git make curl
curl -sSL https://get.docker.com | sh && sudo usermod -aG docker $USER
```

После добавления пользователя в группу `docker` перезайдите в систему. Команды `docker` должны выполняться без `sudo`.

## Сборка и запуск контейнера

```sh
git clone https://github.com/LaIIgreen/webots-ros2-suv.git
cd webots-ros2-suv/docker
make build
./start.sh
```

`make build` один раз скачивает ROS 2 Humble, Webots 2023b и Python-зависимости. Это может занять около часа. `./start.sh` копирует пакеты в контейнер `ulstu-hiber` и открывает порты:

- терминал: `docker exec -it ulstu-hiber bash`
- VS Code в браузере: http://localhost:10002
- поток Webots: http://localhost:10003
- панель робота: http://localhost:10001

Остановить и удалить контейнер вместе с копией исходников:

```sh
make destroy FLAVOR=hiber
```

## Запуск симуляции внутри контейнера

Подключитесь к контейнеру и соберите workspace. Симлинки на `webots_ros2_suv` и `robot_interfaces` скрипт уже создаёт.

```sh
docker exec -it ulstu-hiber bash
cd ~/ros2_ws
colcon build --symlink-install
source install/setup.bash
ros2 launch webots_ros2_suv robot_launch.py
```

В каждом новом терминале контейнера перед запуском нужен `source ~/ros2_ws/install/setup.bash` (он также подключается из `~/.bashrc` при интерактивном входе).

Веса нейросетей в репозиторий не входят. Если узел их требует, скачайте архив с [Яндекс.Диска](https://disk.yandex.ru/d/SiHdbj_grmqD4A) и распакуйте содержимое в `webots_ros2_suv/resource/` на хосте до `./start.sh`. Скрипт копирует эту папку в контейнер.
