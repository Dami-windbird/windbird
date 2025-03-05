# 第一阶段：构建依赖
FROM python:3.11-slim as builder

# 设置清华源
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

# 设置pip清华源
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 安装系统依赖
RUN apt-get update && apt-get install -y \
  gcc \
  default-libmysqlclient-dev \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# 第二阶段：生产镜像
FROM python:3.11-slim

WORKDIR /code

# 从builder阶段复制已安装的包
COPY --from=builder /root/.local /root/.local

# 复制项目文件到工作目录
COPY . /code/
COPY ../manage.py /code/

ENV PATH=/root/.local/bin:$PATH
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "windbird.wsgi"] 
