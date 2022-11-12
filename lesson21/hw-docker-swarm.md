# Использование Docker Swarm

- Создаем новую ветку в репозитории с именем hw-14_docker-swarm

- Закомментируйте в файле docker-compose.yml следующие строчки
```
        # healthcheck:
        #     test: ["CMD", "curl", "-f", "http://backend:8081/api/status"]
        #     interval: 10m
        #     timeout: 10s
        #     retries: 3
```
- Создайте в корне репозитория docker-compose.stack.yml

```
version: "3"
services:
    frontend:
        deploy:
            replicas: 2
            placement:
                constraints: [node.role == manager]
    backend:
        deploy:
            replicas: 2
            placement:
                constraints: [node.role == manager]
    mongo:
        deploy:
            replicas: 1
            placement:
                constraints: [node.role == manager]
```

- Инициализируйте Swarm Mode на своем Docker Host-е
```
docker swarm init
```

- Проверьте достуные Node-ы
```
docker node ls
```

-  Если вы успешно сделали прошлое ДЗ, попробуйте поднять Docker Stack с использованием основного конфига и вспомогательного
```
docker stack deploy -c docker-compose.yml -c docker-compose.stack.yml realworld
```

## Результатом домашнего задания будет

- Оформленный файл README.MD в папке hw-14_docker-swarm с последовательностью Ваших действий
- Преподователь должен иметь возможность произвести установку продукта RealWorld, на базе ваших файлов
- Созданный Pull Request из ветки hw-14_docker-swarm в основную ветку main (или в другую определенную основной в настройках репозитория)

## В качестве НЕОБЯЗАТЕЛЬНОГО дополнительного задания
- Можете найти причину, почему healthcheck не работает в режиме Swarm Mode

#  Раздел "Мотивация"

- У вас все получится!!!