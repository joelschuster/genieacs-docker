#!/bin/sh
set -e

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo add-apt-repository -y ppa:chris-lea/redis-server
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-add-repository -y ppa:brightbox/ruby-ng

sudo apt-get -qq update
sudo apt-get -y install tmux mongodb-org redis-server nodejs ruby2.1 ruby2.1-dev git build-essential libsqlite3-dev

sudo npm install -g coffee-script
sudo npm install -g nodemon
sudo gem install rails --no-ri --no-rdoc

sudo chmod -R 777 ./tmp

#GenieACS
git clone https://github.com/zaidka/genieacs.git
cd genieacs/
npm install
npm run configure
npm run compile
cd ..

#GenieACS GUI
git clone https://github.com/zaidka/genieacs-gui
cd genieacs-gui/
bundle
cp config/summary_parameters-sample.yml config/summary_parameters.yml
cp config/index_parameters-sample.yml config/index_parameters.yml
cp config/parameter_renderers-sample.yml config/parameter_renderers.yml
cp config/parameters_edit-sample.yml config/parameters_edit.yml
cp config/roles-sample.yml config/roles.yml
cp config/users-sample.yml config/users.yml
cp config/graphs-sample.json.erb config/graphs.json.erb
cd ..

mkdir -p /data/db

cat << EOF > ./genieacs-start.sh
#!/bin/sh

/usr/bin/mongod --fork --logpath /var/log/mongod.log
service redis-server start

if tmux has-session -t 'genieacs'; then
  echo "GenieACS is already running."
  echo "To stop it use: ./genieacs-stop.sh"
  echo "To attach to it use: tmux attach -t genieacs"
else
  tmux new-session -s 'genieacs' -d
  tmux send-keys './genieacs/bin/genieacs-cwmp' 'C-m'
  tmux split-window
  tmux send-keys './genieacs/bin/genieacs-nbi' 'C-m'
  tmux split-window
  tmux send-keys './genieacs/bin/genieacs-fs' 'C-m'
  tmux split-window
  tmux send-keys 'cd genieacs-gui' 'C-m'
  tmux send-keys 'rails server' 'C-m'
  tmux select-layout tiled 2>/dev/null
  tmux rename-window 'GenieACS'

  echo "GenieACS has been started in tmux session 'geneiacs'"
  echo "To attach to session, use: tmux attach -t genieacs"
  echo "To switch between panes use Ctrl+B-ArrowKey"
  echo "To deattach, press Ctrl+B-D"
  echo "To stop GenieACS, use: ./genieacs-stop.sh"
fi
EOF

cat << EOF > ./genieacs-stop.sh
#!/bin/sh
if tmux has-session -t 'genieacs' 2>/dev/null; then
  tmux kill-session -t genieacs 2>/dev/null
  echo "GenieACS has been stopped."
else
  echo "GenieACS is not running!"
fi
EOF

chmod +x genieacs-start.sh genieacs-stop.sh

echo
echo "DONE!"
echo "GenieACS has been sucessfully installed. Start/stop it using the following commands:"
echo "./genieacs-start.sh"
echo "./genieacs-stop.sh"