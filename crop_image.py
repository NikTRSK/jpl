import numpy as np
import cv2
import os

def process_images(src_folder = "prism", dst_folder = "."):
  if not os.path.exists(dst_folder + "/original"):
    os.makedirs(dst_folder + "/original")

  if not os.path.exists(dst_folder + "/truths"):
    os.makedirs(dst_folder + "/truths")

  for image in os.listdir(src_folder):
    # Load the image
    img = cv2.imread('1.png',cv2.IMREAD_UNCHANGED)
    # Get the crops from both
    original_crop, ground_truth_crop = split_image_in_half(img)
    os.path.join(dst_folder + '/original/', image)
    # Save the cropped images
    cv2.imwrite(os.path.join(dst_folder + '/original/', image), original_crop)
    cv2.imwrite(os.path.join(dst_folder + '/truths/', image), ground_truth_crop)

def split_image_in_half(image):
  height = int(image.shape[0])
  width = int(image.shape[1])
  original_crop = image[0:height, 0:int(width/2)] # y1:y2, x1:x2
  ground_truth_crop = image[0:height, int(width/2):width] # y1:y2, x1:x2
  return original_crop, ground_truth_crop

process_images('train')