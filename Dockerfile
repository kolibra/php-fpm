FROM php:8.3-fpm-bookworm

MAINTAINER Maciej Prokopiuk

LABEL framework="Magento"
LABEL environment="development"
LABEL maintainer="Maciej Prokopiuk"
LABEL team="Kolibra Team"
LABEL description="Skeleton for Magento application based on Adobe Commerce Cloud environment. Uses php-fpm sock listening daemon, /var/www/html/ as main Magento directory and magento:magento user as owner."

# Add user, create directory, adjust privileges
ARG UID=1000
ARG USERNAME=magento
ARG USER_DIR=/var/www
ARG APP_DIR=${USER_DIR}/html

RUN groupadd -g ${UID} ${USERNAME} \
    && useradd -g ${UID} -u ${UID} -s /bin/bash -d ${USER_DIR} ${USERNAME} \
    && echo "${USERNAME}:12345678" | chpasswd \
    && usermod -aG sudo ${USERNAME} \
    && mkdir -p ${APP_DIR} \
    && mkdir /var/run/php-fpm \
    && mkdir /docker-entrypoint-initphp.d

# Prepare for installation of libraries
RUN apt-get update \
    && apt-get upgrade -y

# Install required libraries
RUN apt-get install -y \
    cron \
    curl \
    zip \
    libbz2-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    libpng-dev \
    libwebp-dev \
    libxml2 \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    zlib1g-dev

# Install additional libraries
RUN apt-get install -y \
    bash-completion \
    ca-certificates \
    gnupg \
    iputils-ping \
    jq \
    locales \
    lsof \
    mariadb-client \
    mc \
    net-tools \
    procps \
    sudo \
    vim \
    watch \
    wget

RUN rm -rf /var/lib/apt/lists/*



# Install PHP libraries
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    bz2 \
#    calendar \
    gd \
    intl \
    mbstring \
    opcache \
    pdo_mysql \
    soap \
    sockets \
    xsl \
    zip

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

#COPY --from=mariadb:10.6 /usr/bin/mysqladmin /usr/local/bin/mysqladmin
#COPY --from=mariadb:10.6 /usr/lib/x86_64-linux-gnu/libssl.so.1.1 /usr/lib/libssl.so.1.1
#COPY --from=mariadb:10.6 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 /usr/lib/libcrypto.so.1.1

COPY ./config/usr/local/bin/mysqladmin /usr/local/bin/
COPY ./config/usr/local/bin/mhsendmail /usr/local/bin/

COPY ./config/usr/lib/libcrypto.so.1.1 /usr/lib/libcrypto.so.1.1
COPY ./config/usr/lib/libssl.so.1.1 /usr/lib/libssl.so.1.1

# Install composer
RUN curl -fsSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Install node
#RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -



# Copy users config files
COPY ./config/users/magento/.bashrc ${USER_DIR}
COPY ./config/users/magento/.selected_editor ${USER_DIR}
COPY ./config/users/magento/.config/mc/ini ${USER_DIR}/.config/mc/ini
RUN chown ${USERNAME}:${USERNAME} -R ${USER_DIR}

COPY ./config/users/root/.bashrc /root/
COPY ./config/users/root/.selected_editor ${USER_DIR}
COPY ./config/users/root/.config/mc/ini /root/.config/mc/ini

COPY ./config/etc/default/locale /etc/default/
COPY ./config/etc/sudoers.d/${USERNAME} /etc/sudoers.d/

# Copy PHP config files
COPY ./config/php-settings/usr/local/etc/php/php.ini              /usr/local/etc/php/php.ini
COPY ./config/php-settings/usr/local/etc/php/conf.d/*             /usr/local/etc/php/conf.d/

COPY ./config/php-settings/usr/local/etc/php-fpm.conf             /usr/local/etc/php-fpm.conf
COPY ./config/php-settings/usr/local/etc/php-fpm.d/www.conf       /usr/local/etc/php-fpm.d/www.conf
COPY ./config/php-settings/usr/local/etc/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

COPY ./config/scripts/usr/local/bin/docker-entrypoint /usr/local/bin/



#USER ${UNAME}:${UNAME}

WORKDIR ${APP_DIR}

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
