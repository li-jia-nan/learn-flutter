import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:my_app/player_page.dart';
import 'package:video_player/video_player.dart';

// 100 public MP4 URLs, ordered by file size (smallest first).
// Checked on 2026-10-17: HTTP 206 + video/mp4 + MP4 ftyp header.
// Full playback was not tested in Flutter. Hugging Face URLs use redirects.
const List<String> testVideoUrls = <String>[
  // 001: drone flying over office building 604 (0.53 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-drone-flying-over-office-building-604_clip_1.mp4",
  // 002: a young athlete woman pedaling on a stationary bike over 50961 (0.53 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-a-young-athlete-woman-pedaling-on-a-stationary-bike-over-50961_clip_1.mp4",
  // 003: front of a car with a stylish woman behind the 44549 (0.57 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-front-of-a-car-with-a-stylish-woman-behind-the-44549_clip_1.mp4",
  // 004: drone flying 579 (0.60 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-drone-flying-579_clip_1.mp4",
  // 005: reflection of a stylish woman in a car mirror 44553 (0.61 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-reflection-of-a-stylish-woman-in-a-car-mirror-44553_clip_1.mp4",
  // 006: woman putting on makeup inside a sports car 44552 (0.64 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-woman-putting-on-makeup-inside-a-sports-car-44552_clip_1.mp4",
  // 007: person cycling on bridge 1590 (0.65 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-person-cycling-on-bridge-1590_clip_1.mp4",
  // 008: woman standing in front of a solar panel 4880 (0.69 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-woman-standing-in-front-of-a-solar-panel-4880_clip_1.mp4",
  // 009: cellphone under a lamp 1793 (0.72 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-cellphone-under-a-lamp-1793_clip_1.mp4",
  // 010: animation of buildings popping up on a street 99712 (0.76 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-animation-of-buildings-popping-up-on-a-street-99712_clip_1.mp4",
  // 011: desk in an office 3098 (0.81 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-desk-in-an-office-3098_clip_1.mp4",
  // 012: speedometer of an accelerating car 2675 (0.81 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-speedometer-of-an-accelerating-car-2675_clip_1.mp4",
  // 013: bmw in a parking lot 3527 (0.82 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-bmw-in-a-parking-lot-3527_clip_1.mp4",
  // 014: a young athlete cleans the sweat off his forehead while 50975 (0.82 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-a-young-athlete-cleans-the-sweat-off-his-forehead-while-50975_clip_1.mp4",
  // 015: young stylish woman getting out of a sports car 44543 (0.84 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-young-stylish-woman-getting-out-of-a-sports-car-44543_clip_1.mp4",
  // 016: cyclist sign next to a road vertical shot 1634 (0.84 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-cyclist-sign-next-to-a-road-vertical-shot-1634_clip_1.mp4",
  // 017: drone in detail on white surface 620 (0.87 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-drone-in-detail-on-white-surface-620_clip_1.mp4",
  // 018: plane on an airstrip 3411 (0.87 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Airplane/mixkit-plane-on-an-airstrip-3411_clip_1.mp4",
  // 019: two cyclists biking outdoors 1637 (0.87 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-two-cyclists-biking-outdoors-1637_clip_1.mp4",
  // 020: a young woman takes a breath before continuing with her 50972 (0.89 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-a-young-woman-takes-a-breath-before-continuing-with-her-50972_clip_1.mp4",
  // 021: well dressed businessman sending messages on his cell phone 4805 (0.91 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-well-dressed-businessman-sending-messages-on-his-cell-phone-4805_clip_1.mp4",
  // 022: industrial machine working 2230 (0.92 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-industrial-machine-working-2230_clip_1.mp4",
  // 023: detailed close up view of a sophisticated drone 44722 (0.92 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Airplane/mixkit-detailed-close-up-view-of-a-sophisticated-drone-44722_clip_1.mp4",
  // 024: man holding a drone 580 (0.92 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Airplane/mixkit-man-holding-a-drone-580_clip_1.mp4",
  // 025: woman getting ready in the rearview mirror of a car 44551 (0.93 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-woman-getting-ready-in-the-rearview-mirror-of-a-car-44551_clip_1.mp4",
  // 026: man in hard hat flying a drone 602 (0.93 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-man-in-hard-hat-flying-a-drone-602_clip_1.mp4",
  // 027: business woman working from home 4956 (0.94 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-business-woman-working-from-home-4956_clip_1.mp4",
  // 028: panorama from the window of an airplane at dusk 40102 (0.94 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Airplane/mixkit-panorama-from-the-window-of-an-airplane-at-dusk-40102_clip_1.mp4",
  // 029: black cat sitting on a white bed 1537 (0.95 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Cats/mixkit-black-cat-sitting-on-a-white-bed-1537_clip_1.mp4",
  // 030: portrait of a stylish woman inside a sports car 44547 (0.96 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-portrait-of-a-stylish-woman-inside-a-sports-car-44547_clip_1.mp4",
  // 031: drone in the sky at a city 581 (0.97 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-drone-in-the-sky-at-a-city-581_clip_1.mp4",
  // 032: woman lighting a cigarette next to a sports car 44550 (0.97 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-woman-lighting-a-cigarette-next-to-a-sports-car-44550_clip_1.mp4",
  // 033: man in hard hat flying drone on side of the 605 (0.99 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-man-in-hard-hat-flying-drone-on-side-of-the-605_clip_1.mp4",
  // 034: empty airport luggage cart close up 4625 (0.99 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-empty-airport-luggage-cart-close-up-4625_clip_1.mp4",
  // 035: black phone on laptop 247 (0.99 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-black-phone-on-laptop-247_clip_1.mp4",
  // 036: young woman doing makeup inside a car 44548 (1.00 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-young-woman-doing-makeup-inside-a-car-44548_clip_1.mp4",
  // 037: double exposure video of a woman and the sky 2531 (1.00 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Airplane/mixkit-double-exposure-video-of-a-woman-and-the-sky-2531_clip_1.mp4",
  // 038: hands shown texting on a smartphone 144 (1.00 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-hands-shown-texting-on-a-smartphone-144_clip_1.mp4",
  // 039: animated pedestrian traffic light with a reverse timer 39821 (1.00 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/City/mixkit-animated-pedestrian-traffic-light-with-a-reverse-timer-39821_clip_1.mp4",
  // 040: cat taking a nap 4102 (1.00 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Cats/mixkit-cat-taking-a-nap-4102_clip_1.mp4",
  // 041: a young woman athlete pedaling on a stationary bike 50959 (1.01 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-a-young-woman-athlete-pedaling-on-a-stationary-bike-50959_clip_1.mp4",
  // 042: drone close up 618 (1.02 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-drone-close-up-618_clip_1.mp4",
  // 043: girl meditating in yoga pose in a park 4892 (1.02 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Birds/mixkit-girl-meditating-in-yoga-pose-in-a-park-4892_clip_1.mp4",
  // 044: couple reading a map inside a car 2723 (1.03 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-couple-reading-a-map-inside-a-car-2723_clip_1.mp4",
  // 045: professional woman working in home office 49925 (1.03 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-professional-woman-working-in-home-office-49925_clip_1.mp4",
  // 046: a hipster picking up their bike 1716 (1.04 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-a-hipster-picking-up-their-bike-1716_clip_1.mp4",
  // 047: plane takes off from a beach town 2627 (1.05 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Airplane/mixkit-plane-takes-off-from-a-beach-town-2627_clip_1.mp4",
  // 048: a young stylish woman inside a sports car 44557 (1.05 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-a-young-stylish-woman-inside-a-sports-car-44557_clip_1.mp4",
  // 049: sky through a plane window 4368 (1.07 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Airplane/mixkit-sky-through-a-plane-window-4368_clip_1.mp4",
  // 050: accelerating car dashboard 64 (1.09 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-accelerating-car-dashboard-64_clip_1.mp4",
  // 051: woman in her living room working writing in a notepad 49912 (1.10 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-woman-in-her-living-room-working-writing-in-a-notepad-49912_clip_1.mp4",
  // 052: balaclava assailant steals computer from car 31363 (1.10 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-balaclava-assailant-steals-computer-from-car-31363_clip_1.mp4",
  // 053: hipster reading a book next to a bicycle 1723 (1.12 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-hipster-reading-a-book-next-to-a-bicycle-1723_clip_1.mp4",
  // 054: pink sunset seen from a plane window 4204 (1.13 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Airplane/mixkit-pink-sunset-seen-from-a-plane-window-4204_clip_1.mp4",
  // 055: a guy texting on his smartphone 269 (1.13 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-a-guy-texting-on-his-smartphone-269_clip_1.mp4",
  // 056: siamese cat inside a hat 4103 (1.14 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Cats/mixkit-siamese-cat-inside-a-hat-4103_clip_1.mp4",
  // 057: drone flying with the sky in the background 44642 (1.14 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-drone-flying-with-the-sky-in-the-background-44642_clip_1.mp4",
  // 058: aerial view of natural scenery captured by drone 44643 (1.14 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-aerial-view-of-natural-scenery-captured-by-drone-44643_clip_1.mp4",
  // 059: young stylish woman in a sports car 44541 (1.15 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-young-stylish-woman-in-a-sports-car-44541_clip_1.mp4",
  // 060: animation of a cyclist moving fast 99584 (1.15 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-animation-of-a-cyclist-moving-fast-99584_clip_1.mp4",
  // 061: professional woman writing on a tablet with a stylus 44784 (1.15 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-professional-woman-writing-on-a-tablet-with-a-stylus-44784_clip_1.mp4",
  // 062: flying over a warm and arid landscape at sunrise 3875 (1.15 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-flying-over-a-warm-and-arid-landscape-at-sunrise-3875_clip_1.mp4",
  // 063: streets of a city from a drone shot 42358 (1.16 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-streets-of-a-city-from-a-drone-shot-42358_clip_1.mp4",
  // 064: birds flying low over a lake in a meadow 41417 (1.16 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Birds/mixkit-birds-flying-low-over-a-lake-in-a-meadow-41417_clip_1.mp4",
  // 065: a young woman pedaling on a static bike 50958 (1.16 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-a-young-woman-pedaling-on-a-static-bike-50958_clip_1.mp4",
  // 066: portrait of a baby 4219 (1.16 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Baby/mixkit-portrait-of-a-baby-4219_clip_1.mp4",
  // 067: a visibly tired young black man exercising on a stationary 50983 (1.17 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-a-visibly-tired-young-black-man-exercising-on-a-stationary-50983_clip_1.mp4",
  // 068: small drone soaring high in the sky 44645 (1.17 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-small-drone-soaring-high-in-the-sky-44645_clip_1.mp4",
  // 069: cyclist riding a track in a park 40872 (1.17 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Bicycle/mixkit-cyclist-riding-a-track-in-a-park-40872_clip_1.mp4",
  // 070: woman working on a laptop 251 (1.18 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-woman-working-on-a-laptop-251_clip_1.mp4",
  // 071: cracked birds egg 2566 (1.18 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Birds/mixkit-cracked-birds-egg-2566_clip_1.mp4",
  // 072: clockwork machinery in detail 3650 (1.20 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-clockwork-machinery-in-detail-3650_clip_1.mp4",
  // 073: one way traffic in the city 100 (1.21 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-one-way-traffic-in-the-city-100_clip_1.mp4",
  // 074: woman with glasses working on a computer 4913 (1.21 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-woman-with-glasses-working-on-a-computer-4913_clip_1.mp4",
  // 075: a person in the street messaging on a smartphone 1713 (1.21 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-a-person-in-the-street-messaging-on-a-smartphone-1713_clip_1.mp4",
  // 076: young woman laughing with her cellphone 4909 (1.22 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-young-woman-laughing-with-her-cellphone-4909_clip_1.mp4",
  // 077: eagle gliding in a clear sky bottom view 1706 (1.22 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Birds/mixkit-eagle-gliding-in-a-clear-sky-bottom-view-1706_clip_1.mp4",
  // 078: close up view of a drone flying outdoors 44644 (1.22 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-close-up-view-of-a-drone-flying-outdoors-44644_clip_1.mp4",
  // 079: stylish woman smoking sitting next to sports car 44544 (1.23 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-stylish-woman-smoking-sitting-next-to-sports-car-44544_clip_1.mp4",
  // 080: trailers on a foggy road 1919 (1.23 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-trailers-on-a-foggy-road-1919_clip_1.mp4",
  // 081: parked red sports car 66 (1.23 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-parked-red-sports-car-66_clip_1.mp4",
  // 082: pleasant chat between two men for a podcast 44034 (1.24 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-pleasant-chat-between-two-men-for-a-podcast-44034_clip_1.mp4",
  // 083: woman on the street watching head on in the foreground 4896 (1.25 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-woman-on-the-street-watching-head-on-in-the-foreground-4896_clip_1.mp4",
  // 084: man with face mask sending audios by cell phone 4918 (1.25 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-man-with-face-mask-sending-audios-by-cell-phone-4918_clip_1.mp4",
  // 085: person petting a black cat 1540 (1.25 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Cats/mixkit-person-petting-a-black-cat-1540_clip_1.mp4",
  // 086: inside a bmw car 3529 (1.25 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-inside-a-bmw-car-3529_clip_1.mp4",
  // 087: a person reading an ebook while drinks coffee 1824 (1.26 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-a-person-reading-an-ebook-while-drinks-coffee-1824_clip_1.mp4",
  // 088: woman using a tablet in the office 42627 (1.26 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-woman-using-a-tablet-in-the-office-42627_clip_1.mp4",
  // 089: portrait of a woman writing in a notepad 49915 (1.27 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-portrait-of-a-woman-writing-in-a-notepad-49915_clip_1.mp4",
  // 090: man controlling a drone with sophisticated technology 44707 (1.27 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Airplane/mixkit-man-controlling-a-drone-with-sophisticated-technology-44707_clip_1.mp4",
  // 091: stylish woman sitting on a sports car 44545 (1.28 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-stylish-woman-sitting-on-a-sports-car-44545_clip_1.mp4",
  // 092: macro closeup video of microchips 1141 (1.28 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-macro-closeup-video-of-microchips-1141_clip_1.mp4",
  // 093: man working on his laptop 308 (1.28 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-man-working-on-his-laptop-308_clip_1.mp4",
  // 094: bee.mp4 (1.29 MB)
  "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
  // 095: friends taking a selfie in a car 43196 (1.30 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-friends-taking-a-selfie-in-a-car-43196_clip_1.mp4",
  // 096: uploading a breakfast instastory 4902 (1.30 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-uploading-a-breakfast-instastory-4902_clip_1.mp4",
  // 097: affectionate couple in a car hanging out together 42509 (1.33 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Car/mixkit-affectionate-couple-in-a-car-hanging-out-together-42509_clip_1.mp4",
  // 098: woman in home office finishing work 49926 (1.33 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Business/mixkit-woman-in-home-office-finishing-work-49926_clip_1.mp4",
  // 099: looking at the clouds from a plane window 2684 (1.34 MB)
  "https://huggingface.co/datasets/FastVideo/Mixkit-Src/resolve/main/Airplane/mixkit-looking-at-the-clouds-from-a-plane-window-2684_clip_1.mp4",
  // 100: butterfly.mp4 (2.43 MB)
  "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
];

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 16 / 9,
        ),
        itemCount: testVideoUrls.length,
        itemBuilder: (BuildContext context, int index) {
          final videoUrl = testVideoUrls[index];
          return _VideoListItem(key: ValueKey(videoUrl), videoUrl: videoUrl);
        },
      ),
    );
  }
}

class _VideoListItem extends StatefulWidget {
  const _VideoListItem({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<_VideoListItem> createState() => _VideoListItemState();
}

class _VideoListItemState extends State<_VideoListItem> {
  late final VideoPlayerController _videoPlayerController;
  late final Future<void> _initializeFuture;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeFuture = _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _videoPlayerController.initialize();
    if (!mounted) {
      return;
    }
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      showControls: false,
      errorBuilder: (context, errorMessage) => Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '视频播放失败：$errorMessage',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: InkWell(
        onTap: () {
          final videoUrl = widget.videoUrl;
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (context) => PlayerPage(videoUrl: videoUrl)),
          );
        },
        child: IgnorePointer(
          child: FutureBuilder<void>(
            future: _initializeFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '视频加载失败：${snapshot.error}',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              final controller = _chewieController;
              if (snapshot.connectionState != ConnectionState.done || controller == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  Chewie(controller: controller),
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 48,
                      color: Colors.white70,
                      semanticLabel: '播放视频',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
