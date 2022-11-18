# Docker

## Критерии приема

- Должен быть оформлен Pull Request в основную ветку с указанием в качестве Reviewer, sergeykudelin.
- В описание Pull Request должны фигурировать ссылки на страницы образов в DockerHub
- Все файлы должны быть закоммичены по мере прохождения задания.
 
## Цель: Посмотрим решение на базе проектов под все языки\фреймворки "RealWorld" - https://github.com/gothinkster

- Создаем новую ветку hw_19 в вашем репозитории

- Загрузим одну из реализаций backend данного проекта - https://github.com/gothinkster/hapijs-realworld-example-app в каталог "backend" вашего репозитория.

- Удалим внутри .git 
```
rm -rdf backend/.git
```

- Так же загрузим реализацию frontend - https://github.com/gothinkster/react-redux-realworld-example-app в каталог "frontend" вашего репозитория

- Удалим внутри .git каталог
```
rm -rdf frontend/.git
```

- Создаем аккаунт https://hub.docker.com если еще нет

- Давайте соберем проект frontend в контейнер, создаем Dockerfile со следующим содержимым

```
FROM node:lts as build
COPY . .
RUN npm install && npm run build

FROM nginx:latest
COPY --from=build ./build /usr/share/nginx/html
```

- Соберем образ frontend

```
docker build -t <YourAccountDockerHub>/hillel-frontend:0.0.1 .

example: docker build -t hilleldevops102021/hillel-frontend:0.0.1 .
```

- Загрузим его в DockerHub
```
docker push <YourAccountDockerHub>/hillel-frontend:0.0.1

example: docker push hilleldevops102021/hillel-frontend:0.0.1 
```

- Соберем backend по такому же сценарию
```
cd ../backend

docker build -t <YourAccountDockerHub>/hillel-backend:0.0.1 .

docker push  <YourAccountDockerHub>/hillel-backend:0.0.1
```

## Необязательно: Самостоятельно ознакомьтесь с проектом в рамках текущих репозиториев которые мы использовали для сборки.

- попробуйте сформировать каких компонентов нам еще не хватает
- разберитесь как frontend взаимодействует с backend [Single Page Application](https://en.wikipedia.org/wiki/Single-page_application)


# У вас все получится!!!