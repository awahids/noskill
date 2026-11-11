set -e
. "$(dirname "$0")/../base.sh"
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
