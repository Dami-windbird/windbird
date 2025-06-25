# 第一阶段：构建依赖
FROM python:3.12-slim AS builder

RUN find /etc/apt -type f -exec sed -i \
    -e 's|http://deb.debian.org|http://mirrors.aliyun.com|g' \
    -e 's|http://security.debian.org|http://mirrors.aliyun.com/debian-security|g' \
    {} +

RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple && \
    pip config set install.trusted-host mirrors.aliyun.com

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc default-libmysqlclient-dev pkg-config libmariadb-dev libmariadb3 python3-dev build-essential && \
    rm -rf /var/lib/apt/lists/*

COPY windbird/requirements.txt .
COPY pyproject.toml poetry.lock* ./

ENV POETRY_VERSION=1.8.2 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_KEYRING=0

ENV PATH="/root/.local/bin:$PATH"
RUN python -m pip install -i https://mirrors.aliyun.com/pypi/simple --trusted-host mirrors.aliyun.com poetry==$POETRY_VERSION

RUN poetry install --no-root --no-ansi -vvv --no-cache && pip list

# 第二阶段：生产镜像
FROM python:3.12-slim

WORKDIR /code

COPY --from=builder /usr/local /usr/local

COPY --from=builder /usr/lib/x86_64-linux-gnu/libmariadb.so.3 /usr/lib/x86_64-linux-gnu/libmariadb.so.3

COPY . /code/

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "windbird.wsgi"]
