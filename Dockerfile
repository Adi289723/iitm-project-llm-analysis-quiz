FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

WORKDIR /app

# Install ALL dependencies including Playwright deps upfront
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    curl wget gnupg ca-certificates ffmpeg libopus0 \
    libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 \
    libcups2 libdbus-1-3 libdrm2 libgbm1 libgtk-3-0 libnspr4 \
    libnss3 libwayland-client0 libxcomposite1 libxdamage1 libxfixes3 \
    libxkbcommon0 libxrandr2 xdg-utils libu2f-udev libvulkan1 \
    fonts-liberation fonts-noto fonts-unifont \
    && rm -rf /var/lib/apt/lists/*

# Install pip packages
RUN python3 -m pip install --no-cache-dir --upgrade pip

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright AND browsers in the standard location
RUN python3 -m pip install playwright && \
    python3 -m playwright install chromium

# Copy app
COPY . .

# NO USER SWITCH - run as root
EXPOSE 7860

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python3 -c "import requests; requests.get('http://localhost:7860/health', timeout=5)"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
