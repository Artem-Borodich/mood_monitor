# ===============================
# Скрипт запуска проекта "Mood Monitor"
# ===============================

# 1️⃣ Проверка и запуск службы PostgreSQL
$service = Get-Service -Name postgresql* -ErrorAction SilentlyContinue
if ($service -eq $null) {
    Write-Host "Служба PostgreSQL не найдена. Проверьте установку."
} elseif ($service.Status -ne "Running") {
    Write-Host "Запускаем службу PostgreSQL..."
    Start-Service -Name $service.Name
} else {
    Write-Host "PostgreSQL уже запущен."
}

# 2️⃣ Установка переменной окружения для backend
# Замените 'ТВОЙ_ПАРОЛЬ' на пароль от пользователя postgres
$env:DATABASE_URL = "postgresql+psycopg2://postgres:postgres@localhost:5432/mood_db"

# 3️⃣ Запуск backend (FastAPI) в отдельном окне PowerShell
Start-Process powershell -ArgumentList "-NoExit", "-Command `"cd 'C:\mood_project\backend'; .\venv\Scripts\Activate.ps1; uvicorn main:app --reload --host 0.0.0.0 --port 8000`""

# 4️⃣ Небольшая пауза, чтобы backend успел подняться
Start-Sleep -Seconds 5

# 5️⃣ Запуск Flutter (Windows Desktop) в отдельном окне PowerShell
Start-Process powershell -ArgumentList "-NoExit", "-Command `"cd 'C:\mood_project\flutter_app'; flutter run -d windows`""