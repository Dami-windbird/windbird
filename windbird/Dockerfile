# 基础镜像
FROM python:3.11.10-slim-bookworm

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 创建工作目录
WORKDIR /code

# 安装系统依赖
RUN apt-get update && apt-get install -y \
  gcc \
  libmariadb-dev-compat \
  && rm -rf /var/lib/apt/lists/*

# 安装Python依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .

# 收集静态文件
RUN python manage.py collectstatic --noinput

# 添加版本验证步骤
RUN python --version

# 启动命令
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "windbird.wsgi"] 