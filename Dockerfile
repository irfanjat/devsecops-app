FROM python:3.12-slim AS builder

WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.12-slim

RUN addgroup --system --gid 1000 appuser && \
    adduser --system --uid 1000 --gid 1000 appuser

WORKDIR /app

COPY --from=builder /root/.local /home/appuser/.local
COPY app/ .

ENV PATH=/home/appuser/.local/bin:$PATH

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
