# https://jtreminio.com/blog/running-docker-containers-as-current-host-user/
#
# Construction de l'image :
#
# shell> docker build --build-arg USER_ID=$(id -u ${USER}) --build-arg GROUP_ID=$(id -g ${USER}) -t symfony .
#
# Execution de l'image (le projet est dans ./app):
#
# shell> docker run -it -v $PWD/app:/app -u $(id -u ${USER}):$(id -g ${USER}) -t symfony
#

FROM php:7.4.19-cli

RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y apt-utils git unzip wget

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    cp composer.phar /usr/local/bin/composer


RUN wget https://get.symfony.com/cli/installer -O - | bash && \
    mv /root/.symfony/bin/symfony /usr/local/bin/symfony

ARG USER_ID
ARG GROUP_ID

RUN mkdir /app

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    if getent passwd ${USER_ID}; then userdel `id -nu ${USER_ID}`; fi &&\
    if getent group ${GROUP_ID} ; then groupdel `getent group ${GROUP_ID} | cut -f1 -d:`; fi &&\
    groupadd -g ${GROUP_ID} me &&\
    useradd -l -u ${USER_ID} -g me me &&\
    install -d -m 0755 -o me -g me /home/me &&\
    chown --changes --silent --no-dereference --recursive \
           ${USER_ID}:${GROUP_ID} \
        /home/me \
        /app \
;fi

USER me

RUN git config --global user.name me && git config --global user.email "me@example.com"

WORKDIR /app


CMD [ "bash" ]