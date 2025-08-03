#!/usr/bin/env python3

import os
import subprocess
from datetime import datetime


# Конфигурация
REPO_PATHS = [
    "/Users/dyuzha/.dotfiles",
    "/Users/dyuzha/scripts",
    "/Users/dyuzha/m-infra",
    "/Users/dyuzha/obs-home",
    "/Users/dyuzha/kp",
]


# Цвета для вывода
RED = "\033[1;31m"
GREEN = "\033[1;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[1;34m"
RESET = "\033[0m"


def check_repo_status(repo_path):
    """Проверяет статус Git-репозитория."""
    os.chdir(repo_path)
    repo_name = os.path.basename(repo_path)

    # Получаем текущую ветку
    branch = subprocess.getoutput("git branch --show-current")

    # Проверяем наличие изменений
    status = subprocess.getoutput("git status --porcelain")
    unpushed = subprocess.getoutput("git log @{u}..HEAD --oneline")

    # Проверяем, нужно ли pull
    subprocess.run(["git", "fetch"])
    behind = subprocess.getoutput("git rev-list HEAD..origin/" + branch + " --count")

    return {
        "name": repo_name,
        "path": repo_path,
        "branch": branch,
        "changed": bool(status),
        "uncommitted": status.splitlines() if status else [],
        "unpushed": unpushed.splitlines() if unpushed else [],
        "behind": int(behind) if behind else 0
    }

def generate_report():
    """Генерирует отчет по всем репозиториям."""
    report = []
    for repo in REPO_PATHS:
        if not os.path.exists(os.path.join(repo, ".git")):
            continue
        report.append(check_repo_status(repo))
    return report

def print_report(report):
    """Выводит красивый отчет."""
    print(f"\n{BLUE}=== Git Repositories Status Report ==={RESET}")
    print(f"{YELLOW}Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{RESET}\n")

    for repo in report:
        color = RED if repo["changed"] or repo["unpushed"] or repo["behind"] else GREEN
        print(f"{color}▌ {repo['name']} [{repo['branch']}]{RESET}")
        print(f"Path: {repo['path']}")

        if repo["changed"]:
            print(f"{RED}  ✗ Uncommitted changes:{RESET}")
            for change in repo["uncommitted"]:
                print(f"    {change}")

        if repo["unpushed"]:
            print(f"{YELLOW}  ! Unpushed commits ({len(repo['unpushed'])}):{RESET}")
            for commit in repo["unpushed"]:
                print(f"    {commit}")

        if repo["behind"]:
            print(f"{YELLOW}  ▼ Behind remote by {repo['behind']} commit(s){RESET}")

        if not repo["changed"] and not repo["unpushed"] and not repo["behind"]:
            print(f"{GREEN}  ✓ Clean{RESET}")

        print()

if __name__ == "__main__":
    report = generate_report()
    print_report(report)

    # Проверяем, есть ли проблемы
    problems = any(repo["changed"] or repo["unpushed"] or repo["behind"] for repo in report)
    if problems:
        print(f"{RED}⚠️ Внимание: Есть незакоммиченные или неотправленные изменения!{RESET}")
        # Можно добавить уведомление в систему
        # subprocess.run(["notify-send", "Git Alert", "Есть незакоммиченные изменения"])
    else:
        print(f"{GREEN}✓ Все репозитории синхронизированы{RESET}")
