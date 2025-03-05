FROM centos:7

# 安装Python 3.11
RUN yum install -y https://repo.ius.io/ius-release-el7.rpm
RUN yum install -y python3.11 python3.11-devel

# 设置默认Python版本
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# 安装系统依赖
RUN yum install -y \
  gcc \
  mysql-devel \
  && yum clean all

# 设置pip清华源
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /code

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

RUN python3 manage.py collectstatic --noinput

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "windbird.wsgi"] 