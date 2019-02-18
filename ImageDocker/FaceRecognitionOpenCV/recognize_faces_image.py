# USAGE
# python recognize_faces_image.py --encodings encodings.pickle --image examples/example_01.png 

import time
print("{} [INFO] Preparing".format(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))))

# import the necessary packages
import face_recognition
import argparse
import pickle
import cv2
import numpy
from PIL import Image, ImageFont, ImageDraw

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-e", "--encodings", required=True,
	help="path to serialized db of facial encodings")
ap.add_argument("-i", "--image", required=True,
	help="path to input image")
ap.add_argument("-o", "--output", type=str,
	help="path to output image")
ap.add_argument("-y", "--display", type=int, default=1,
	help="whether or not to display output frame to screen")
ap.add_argument("-d", "--detection-method", type=str, default="cnn",
	help="face detection model to use: either `hog` or `cnn`")
args = vars(ap.parse_args())

# load the known faces and embeddings
print("{} [INFO] Loading encoded pickle ...".format(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))))
data = pickle.loads(open(args["encodings"], "rb").read())

# load the input image and convert it from BGR to RGB
image = cv2.imread(args["image"])
rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

# detect the (x, y)-coordinates of the bounding boxes corresponding
# to each face in the input image, then compute the facial embeddings
# for each face
print("{} [INFO] recognizing faces...".format(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))))
boxes = face_recognition.face_locations(rgb,
	model=args["detection_method"])
encodings = face_recognition.face_encodings(rgb, boxes)

# initialize the list of names for each face detected
names = []

# loop over the facial embeddings
for encoding in encodings:
	# attempt to match each face in the input image to our known
	# encodings
	matches = face_recognition.compare_faces(data["encodings"],
		encoding, tolerance=0.5)
	name = "Unknown"

	# check to see if we have found a match
	if True in matches:
		# find the indexes of all matched faces then initialize a
		# dictionary to count the total number of times each face
		# was matched
		matchedIdxs = [i for (i, b) in enumerate(matches) if b]
		counts = {}

		# loop over the matched indexes and maintain a count for
		# each recognized face face
		for i in matchedIdxs:
			name = data["names"][i]
			counts[name] = counts.get(name, 0) + 1

		# determine the recognized face with the largest number of
		# votes (note: in the event of an unlikely tie Python will
		# select first entry in the dictionary)
		name = max(counts, key=counts.get)
	
	# update the list of names
	names.append(name)

font_size = 14
font = ImageFont.truetype('/System/Library/Fonts/PingFang.ttc', font_size)
font_color = (255, 255, 255)

# loop over the recognized faces
for ((top, right, bottom, left), name) in zip(boxes, names):
	# draw the predicted face name on the image

	# Draw a box around the face
	cv2.rectangle(image, (left, top), (right, bottom), (100, 100, 100), 1)

	display_name = "{}".format(name)
	text_size = font.getsize(display_name)
	text_width = text_size[0]
	text_height = text_size[1]

	# Draw a label with a name below the face
	label_bgcolor      = (80,  80,  80)
	label_border_color = (150, 150, 150)
	label_triangle_top = bottom + 5
	label_midpoint = left + round((right - left) / 2)
	label_left   = label_midpoint - round(text_width / 2) - 5 #left
	label_top    = bottom + 15
	label_right  = label_midpoint + round(text_width / 2) + 5 #right + 10
	label_bottom = label_top + round(text_height) + 5 #bottom + 35
	label_text_x = label_left + 2 #left + 2
	label_text_y = label_top # + round(text_height / 2) #bottom + 30
	label_left_top     = (label_left,  label_top)
	label_right_top    = (label_right, label_top)
	label_left_bottom  = (label_left,  label_bottom)
	label_right_bottom = (label_right, label_bottom)

	# background of the label
	cv2.rectangle(image, label_left_top, label_right_bottom, label_bgcolor, cv2.FILLED)

	pt1 = (label_midpoint, label_triangle_top)
	pt2 = (label_midpoint - 7, label_top)
	pt3 = (label_midpoint + 7, label_top)
	triangle_cnt = numpy.array( [pt1, pt2, pt3] ).astype(numpy.int32)
	cv2.drawContours(image, [triangle_cnt], 0, label_bgcolor, cv2.FILLED)

	# border
	cv2.line(image, pt1, pt2, label_border_color,1)
	cv2.line(image, pt1, pt3, label_border_color,1)
	cv2.line(image, label_left_top,    pt2,                label_border_color, 1)
	cv2.line(image, pt3,               label_right_top,    label_border_color, 1)
	cv2.line(image, label_left_top,    label_left_bottom,  label_border_color, 1)
	cv2.line(image, label_right_top,   label_right_bottom, label_border_color, 1)
	cv2.line(image, label_left_bottom, label_right_bottom, label_border_color, 1)

	# Draw the name
	#cv2.putText(image, name , (label_text_x, label_text_y), font, 0.5, label_text_color, 1)
	#font.draw_text(image, (3, 3), '你好', 24, label_text_color)
	print("RECOGNITION RESULT: {} {} {} {} {}".format(left, top, right, bottom, name))

img_PIL = Image.fromarray(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
draw = ImageDraw.Draw(img_PIL)

for ((top, right, bottom, left), name) in zip(boxes, names):
	
	display_name = "{}".format(name)
	text_size = font.getsize(display_name)
	text_width = text_size[0]
	text_height = text_size[1]

	label_midpoint = left + round((right - left) / 2)
	label_left   = label_midpoint - round(text_width / 2) - 5 #left
	label_top    = bottom + 15
	label_right  = label_midpoint + round(text_width / 2) + 5 #right + 10
	label_bottom = label_top + round(text_height) + 5 #bottom + 35
	label_text_x = label_left + 5 #left + 2
	label_text_y = label_top + 2# + round(text_height / 2) #bottom + 30

	draw.text((label_text_x, label_text_y), display_name, font=font, fill=font_color)

image = cv2.cvtColor(numpy.asarray(img_PIL),cv2.COLOR_RGB2BGR)

# save image
if args["output"] is not None:
	cv2.imwrite(args["output"], image)
	print("{} [INFO] Saved image to {}".format(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time())), args["output"]))

print("{} [INFO] DONE.".format(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))))

# show the output image
# check to see if we are supposed to display the image to
# the screen
if args["display"] > 0:
	cv2.imshow("Image", image)
	cv2.waitKey(0)

