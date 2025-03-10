# 第一阶段：构建依赖
FROM python:3.11-slim as builder

RUN echo "deb https://mirrors.cloud.tencent.com/debian/ bookworm main contrib non-free" > /etc/apt/sources.list && \
  echo "deb https://mirrors.cloud.tencent.com/debian/ bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
  echo "deb https://mirrors.cloud.tencent.com/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list

# 设置pip清华源
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

RUN apt-get update
# 安装系统依赖
RUN apt-get install -y --no-install-recommends \
  gcc \
  default-libmysqlclient-dev \
  pkg-config \
  libmariadb-dev \
  libmariadb3 \
  python3-dev build-essential \
  && rm -rf /var/lib/apt/lists/*

COPY windbird/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# 第二阶段：生产镜像
FROM python:3.11-slim

WORKDIR /code

# 从builder阶段复制已安装的包
COPY --from=builder /root/.local /root/.local
COPY --from=builder /usr/lib/x86_64-linux-gnu/libmariadb.so.3 /usr/lib/x86_64-linux-gnu/libmariadb.so.3

# 复制项目文件到工作目录
COPY . /code/

ENV PATH=/root/.local/bin:$PATH
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "windbird.wsgi"]
