FROM python:3.9

# Instalar dependencias del sistema
RUN apt-get update && \
    apt-get install -y git sshpass openssh-server openssh-client default-mysql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Crear un directorio de trabajo
WORKDIR /app

# Copiar el archivo requirements.txt al contenedor
COPY requirements.txt .

# Instalar las dependencias de Python especificadas en requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiar los archivos del proyecto DBT al contenedor
COPY . /app

# Instalar las dependencias de dbt, incluyendo dbt_utils
RUN dbt deps

# Establecer variables de entorno para la conexión a RDS de MySQL
ENV DBT_PROFILES_DIR=/app/.dbt
ARG MYSQL_PASSWORD_DEV
ENV MYSQL_PASSWORD_DEV=$MYSQL_PASSWORD_DEV
ARG SSH_PASSWORD
ENV SSH_PASSWORD=$SSH_PASSWORD


# Comando de inicio del contenedor
CMD sshpass -p $SSH_PASSWORD ssh -p 22 \
    ubuntu@quantum-v2-devprod-brdg-lb-09381999897f2232.elb.us-east-1.amazonaws.com \
    -o StrictHostKeyChecking=no \
    -L 3306:quantum-v2-dev-rds.cluster-cegv0wkgdkwr.us-east-1.rds.amazonaws.com:3306 \
    -f -N -t && \
    dbt run --models dim_industry --target dev

