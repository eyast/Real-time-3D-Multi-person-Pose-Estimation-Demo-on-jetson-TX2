NETWORKS_DIR="data/networks"
CLASSIFY_DIR="python/training/classification"
DETECTION_DIR="python/training/detection/ssd"
RECOGNIZER_DIR="python/www/recognizer"

# DATA_VOLUME=""\
# --volume $PWD/data:$DOCKER_ROOT/data \
# --volume $PWD/$CLASSIFY_DIR/data:$DOCKER_ROOT/$CLASSIFY_DIR/data \
# --volume $PWD/$CLASSIFY_DIR/models:$DOCKER_ROOT/$CLASSIFY_DIR/models \
# --volume $PWD/$DETECTION_DIR/data:$DOCKER_ROOT/$DETECTION_DIR/data \
# --volume $PWD/$DETECTION_DIR/models:$DOCKER_ROOT/$DETECTION_DIR/models \
# --volume $PWD/$RECOGNIZER_DIR/data:$DOCKER_ROOT/$RECOGNIZER_DIR/data""

DATA_VOLUME="
  --volume $PWD/:$DOCKER_ROOT/data"

#USER_COMMAND="python3 ./pose.py"
#USER_COMMAND = ""

cat /proc/device-tree/model > /tmp/nv_jetson_model

V4L2_DEVICES=" "

for i in {0..9}
do
	if [ -a "/dev/video$i" ]; then
		V4L2_DEVICES="$V4L2_DEVICES --device /dev/video$i "
	fi
done

echo "V4L2_DEVICES:  $V4L2_DEVICES"

DISPLAY_DEVICE=" "

if [ -n "$DISPLAY" ]; then
	sudo xhost +si:localuser:root
	DISPLAY_DEVICE="-e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix"
fi

echo "DISPLAY_DEVICE: $DISPLAY_DEVICE"

sudo docker run --runtime nvidia -it --rm \
    --network host \
    -v /tmp/argus_socket:/tmp/argus_socket \
    -v /etc/enctune.conf:/etc/enctune.conf \
    -v /etc/nv_tegra_release:/etc/nv_tegra_release \
    -v /tmp/nv_jetson_model:/tmp/nv_jetson_model \
    $DISPLAY_DEVICE $V4L2_DEVICES \
    $DATA_VOLUME \
    "banana" $USER_COMMAND
