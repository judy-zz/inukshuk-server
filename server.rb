#!/usr/bin/env ruby
require "eventmachine"
require "em-http-request"
require "em-websocket"
require "yajl"
require "yaml"
require 'sinatra/base'
require 'haml'
require 'thin'
require 'json'
require 'net/telnet'
require "active_support/core_ext"
require 'profanity_filter'

require './client.rb'

$CONFIG = YAML.load_file("config.yml")

require 'pry'
@colors = {}

[[0, 0, 0, "black",],
[0, 0, 128, "navy", ],
[0, 0, 139, "dark blue", "darkblue", "blue4"],
[0, 0, 156, "new midnight blue"],
[0, 0, 205, "medium blue", "mediumblue", "medium blue", "blue3"],
[0, 0, 238, "blue2"],
[0, 0, 255, "blue", "blue", "blue", "blue1"],
[0, 34, 102, "royalblue5"],
[0, 100, 0, "dark green", "darkgreen", "dark green", "darkgreen"],
[0, 104, 139, "deep sky blue"],
[0, 127, 255, "slate blue"],
[0, 128, 0, "green", "green", "green"],
[0, 128, 128, "teal", "teal", "teal"],
[0, 134, 139, "turquoise4"],
[0, 139, 0, "green4"],
[0, 139, 69, "springgreen4"],
[0, 139, 139, "darkcyan", "darkcyan", "cyan4"],
[0, 154, 205, "deepskyblue3"],
[0, 178, 238, "deepskyblue2"],
[0, 191, 255, "deep sky blue", "deepskyblue", "deep sky blue", "deepskyblue1"],
[0, 197, 205, "turquoise3"],
[0, 205, 0, "green3"],
[0, 205, 102, "springgreen3"],
[0, 205, 205, "cyan3"],
[0, 206, 209, "dark turquoise", "darkturquoise", "dark turquoise", "darkturquoise"],
[0, 229, 238, "turquoise2"],
[0, 238, 0, "green2"],
[0, 238, 118, "springgreen2"],
[0, 238, 238, "cyan2"],
[0, 245, 255, "turquoise1"],
[0, 250, 154, "medium spring green", "mediumspringgreen", "medium spring green", "mediumspringgreen"],
[0, 255, 0, "lime", "lime", "green1"],
[0, 255, 127, "spring green", "springgreen", "spring green", "springgreen"],
[0, 255, 255, "cyan", "cyan", "cyan", "cyan1"],
[2, 157, 116, "freespeechaquamarine"],
[3, 3, 3, "grey1"],
[3, 180, 200, "irisblue"],
[5, 5, 5, "grey2"],
[8, 8, 8, "grey3"],
[9, 249, 17, "freespeechgreen"],
[10, 10, 10, "grey4"],
[13, 13, 13, "grey5"],
[15, 15, 15, "grey6"],
[16, 78, 139, "dodgerblue4"],
[18, 18, 18, "grey7"],
[20, 20, 20, "grey8"],
[23, 23, 23, "grey9"],
[24, 116, 205, "dodgerblue3"],
[25, 25, 112, "midnight blue", "midnightblue", "midnight blue", "midnightblue"],
[26, 26, 26, "grey10"],
[28, 28, 28, "grey11"],
[28, 134, 238, "dodgerblue2"],
[30, 144, 255, "dodger blue", "dodgerblue", "dodger blue", "dodgerblue1"],
[31, 31, 31, "grey12"],
[32, 178, 170, "light sea green", "lightseagreen", "light sea green", "lightseagreen"],
[33, 33, 33, "grey13"],
[34, 139, 34, "forest green", "forestgreen", "forest green", "forestgreen"],
[35, 35, 142, "navy blue"],
[35, 142, 35, "medium aquamarine"],
[35, 142, 104, "sea green"],
[36, 24, 130, "dark slate blue"],
[36, 36, 36, "grey14"],
[38, 38, 38, "grey15"],
[39, 64, 139, "royalblue4"],
[41, 41, 41, "grey16"],
[43, 43, 43, "grey17"],
[46, 46, 46, "grey18"],
[46, 139, 87, "sea green", "seagreen", "sea green", "seagreen"],
[47, 47, 79, "midnightblue"],
[47, 79, 47, "darkgreen"],
[47, 79, 79, "dark slate grey", "darkslategray", "darkslategray"],
[48, 48, 48, "grey19"],
[49, 79, 79, "dark slate gray"],
[50, 153, 204, "skyblue"],
[50, 205, 50, "lime green", "limegreen", "lime green", "limegreen"],
[51, 51, 51, "grey20"],
[54, 54, 54, "grey21"],
[54, 100, 139, "steelblue4"],
[56, 56, 56, "grey22"],
[56, 176, 222, "summersky"],
[58, 95, 205, "royalblue3"],
[59, 59, 59, "grey23"],
[60, 179, 113, "medium sea green", "mediumseagreen", "medium sea green", "mediumseagreen"],
[61, 61, 61, "grey24"],
[64, 64, 64, "grey25"],
[64, 224, 208, "turquoise", "turquoise", "turquoise", "turquoise"],
[65, 86, 197, "freespeechblue"],
[65, 105, 225, "royal blue", "royalblue", "royal blue", "royalblue"],
[66, 66, 66, "grey26"],
[66, 66, 111, "cornflowerblue"],
[66, 111, 66, "mediumseagreen"],
[67, 110, 238, "royalblue2"],
[67, 205, 128, "seagreen3"],
[69, 69, 69, "grey27"],
[69, 139, 0, "chartreuse4"],
[69, 139, 116, "aquamarine4"],
[70, 130, 180, "steel blue", "steelblue", "steel blue", "steelblue"],
[71, 60, 139, "slateblue4"],
[71, 71, 71, "grey28"],
[72, 61, 139, "dark slate blue", "darkslateblue", "dark slate blue", "darkslateblue"],
[72, 118, 255, "royalblue1"],
[72, 209, 204, "medium turquoise", "mediumturquoise", "medium turquoise", "mediumturquoise"],
[74, 74, 74, "grey29"],
[74, 112, 139, "skyblue4"],
[74, 118, 110, "darkgreencopper"],
[75, 0, 130, "indigo", "indigo"],
[77, 77, 77, "grey30"],
[77, 77, 255, "neonblue"],
[78, 238, 148, "seagreen2"],
[79, 47, 79, "violet"],
[79, 79, 47, "darkolivegreen"],
[79, 79, 79, "grey31"],
[79, 148, 205, "steelblue3"],
[82, 82, 82, "grey32"],
[82, 139, 139, "darkslategray4"],
[83, 134, 139, "cadetblue4"],
[84, 84, 84, "dim grey"],
[84, 139, 84, "palegreen4"],
[84, 255, 159, "seagreen1"],
[85, 26, 139, "purple4"],
[85, 107, 47, "dark olive green", "darkolivegreen", "dark olive green", "darkolivegreen"],
[87, 87, 87, "grey34"],
[89, 89, 89, "grey35"],
[89, 89, 171, "richblue"],
[92, 51, 23, "baker"],
[92, 64, 51, "verydarkbrown"],
[92, 92, 92, "grey36"],
[92, 172, 238, "steelblue2"],
[93, 71, 139, "mediumpurple4"],
[94, 94, 94, "grey37"],
[95, 158, 160, "cadet blue", "cadetblue", "cadet blue", "cadetblue"],
[95, 159, 159, "cadetblue"],
[96, 123, 139, "lightskyblue4"],
[97, 97, 97, "grey38"],
[99, 86, 136, "free speech grey"],
[99, 99, 99, "grey39"],
[99, 184, 255, "steelblue1"],
[100, 149, 237, "corn flower blue", "cornflowerblue", "cornflower blue", "cornflowerblue"],
[102, 102, 102, "grey40"],
[102, 139, 139, "paleturquoise4"],
[102, 205, 0, "chartreuse3"],
[102, 205, 170, "medium aquamarine", "mediumaquamarine", "medium aquamarine", "aquamarine3"],
[104, 34, 139, "darkorchid4"],
[104, 131, 139, "lightblue4"],
[105, 89, 205, "slateblue3"],
[105, 105, 105, "dim grey", "dimgray", "dim gray", "dimgrey"],
[105, 139, 34, "olivedrab4"],
[105, 139, 105, "darkseagreen4"],
[106, 90, 205, "slate blue", "slateblue", "slate blue", "slateblue"],
[107, 107, 107, "grey42"],
[107, 142, 35, "olive drab", "olivedrab", "olive drab", "olivedrab"],
[108, 123, 139, "slategray4"],
[108, 166, 205, "skyblue3"],
[110, 110, 110, "grey43"],
[110, 123, 139, "lightsteelblue4"],
[110, 139, 61, "darkolivegreen4"],
[111, 66, 66, "salmon"],
[112, 112, 112, "grey44"],
[112, 128, 144, "slate grey", "slate gray", "slategray"],
[112, 138, 144, "slate gray"],
[112, 147, 219, "darkturquoise"],
[112, 219, 147, "aquamarine"],
[112, 219, 219, "mediumturquoise"],
[115, 115, 115, "grey45"],
[117, 117, 117, "grey46"],
[118, 238, 0, "chartreuse2"],
[118, 238, 198, "aquamarine2"],
[119, 136, 153, "light slate grey", "lightslategray", "light slate gray", "lightslategrey"],
[120, 120, 120, "grey47"],
[121, 205, 205, "darkslategray3"],
[122, 55, 139, "mediumorchid4"],
[122, 103, 238, "slateblue2"],
[122, 122, 122, "grey48"],
[122, 139, 139, "lightcyan4"],
[122, 197, 205, "cadetblue3"],
[123, 104, 238, "medium slate blue", "mediumslateblue", "medium slate blue", "mediumslateblue"],
[124, 205, 124, "palegreen3"],
[124, 252, 0, "lawn green", "lawngreen", "lawn green", "lawngreen"],
[125, 38, 205, "purple3"],
[125, 125, 125, "grey49"],
[126, 192, 238, "skyblue2"],
[127, 0, 255, "mediumslate blue"],
[127, 127, 127, "grey50"],
[127, 255, 0, "chart reuse", "chartreuse", "chartreuse", "medium spring green"],
[127, 255, 212, "aquamarine", "aquamarine", "aquamarine", "aquamarine1"],
[128, 0, 0, "maroon", "maroon", "maroon"],
[128, 0, 128, "purple", "purple", "purple"],
[128, 128, 0, "olive", "olive", "olive"],
[128, 128, 128, "grey", "gray"],
[130, 130, 130, "grey51"],
[131, 111, 255, "slateblue1"],
[131, 139, 131, "honeydew 4", "honeydew4"],
[131, 139, 139, "azure4"],
[132, 112, 255, "light slate blue", "lightslateblue"],
[133, 94, 66, "darkwood"],
[133, 99, 99, "dustyrose"],
[133, 133, 133, "grey52"],
[135, 31, 120, "darkpurple"],
[135, 135, 135, "grey53"],
[135, 206, 235, "sky blue", "skyblue", "skyblue"],
[135, 206, 250, "light sky blue", "lightskyblue", "light sky blue", "lightskyblue"],
[135, 206, 255, "skyblue1"],
[137, 104, 205, "mediumpurple3"],
[138, 43, 226, "blue violet", "blueviolet", "blue violet", "blueviolet"],
[138, 138, 138, "grey54"],
[139, 0, 0, "dark red", "darkred", "red4"],
[139, 0, 139, "dark magenta", "darkmagenta", "magenta4"],
[139, 10, 80, "deeppink4"],
[139, 26, 26, "firebrick4"],
[139, 28, 98, "maroon4"],
[139, 34, 82, "violetred4"],
[139, 35, 35, "brown4"],
[139, 37, 0, "orangered4"],
[139, 54, 38, "tomato4"],
[139, 58, 58, "indianred4"],
[139, 58, 98, "hotpink4"],
[139, 62, 47, "coral4"],
[139, 69, 0, "darkorange4"],
[139, 69, 19, "saddle brown", "saddlebrown", "saddle brown", "chocolate4"],
[139, 71, 38, "sienna4"],
[139, 71, 93, "palevioletred4"],
[139, 71, 137, "orchid4"],
[139, 76, 57, "salmon4"],
[139, 87, 66, "lightsalmon4"],
[139, 90, 0, "orange4"],
[139, 90, 43, "tan4"],
[139, 95, 101, "lightpink4"],
[139, 99, 108, "pink4"],
[139, 101, 8, "darkgoldenrod4"],
[139, 102, 139, "plum4"],
[139, 105, 20, "goldenrod4"],
[139, 105, 105, "rosybrown4"],
[139, 115, 85, "burlywood4"],
[139, 117, 0, "gold4"],
[139, 119, 101, "peachpuff4"],
[139, 121, 94, "navajowhite4"],
[139, 123, 139, "thistle4"],
[139, 125, 107, "bisque 4", "bisque4"],
[139, 125, 123, "mistyrose4"],
[139, 126, 102, "wheat4"],
[139, 129, 76, "lightgoldenrod4"],
[139, 131, 120, "antiquewhite4"],
[139, 131, 134, "lavenderblush4"],
[139, 134, 78, "khaki4"],
[139, 134, 130, "seashell 4", "seashell4"],
[139, 136, 120, "cornsilk 4", "cornsilk4"],
[139, 137, 112, "lemonchiffon4"],
[139, 137, 137, "snow 4", "snow4"],
[139, 139, 0, "yellow4"],
[139, 139, 122, "lightyellow4"],
[139, 139, 131, "ivory 4", "ivory4"],
[140, 23, 23, "scarlet"],
[140, 140, 140, "grey55"],
[141, 182, 205, "lightskyblue3"],
[141, 238, 238, "darkslategray2"],
[142, 35, 35, "firebrick"],
[142, 107, 35, "sienna"],
[142, 229, 238, "cadetblue2"],
[143, 143, 143, "grey56"],
[143, 188, 143, "dark sea green", "darkseagreen", "dark sea green", "palegreen"],
[144, 238, 144, "light green", "lightgreen", "palegreen2"],
[145, 44, 238, "purple2"],
[145, 145, 145, "grey57"],
[147, 112, 219, "medium purple", "mediumpurple", "medium purple", "medium orchid"],
[148, 0, 211, "dark violet", "darkviolet", "dark violet", "darkviolet"],
[148, 148, 148, "grey58"],
[150, 150, 150, "grey59"],
[150, 205, 205, "paleturquoise3"],
[151, 105, 79, "darktan"],
[151, 255, 255, "darkslategray1"],
[152, 245, 255, "cadetblue1"],
[152, 251, 152, "pale green", "palegreen", "pale green", "palegreen"],
[153, 50, 204, "dark orchid", "darkorchid", "dark orchid", "darkorchid"],
[153, 50, 205, "darkorchid"],
[153, 153, 153, "grey60"],
[153, 204, 50, "yellowgreen"],
[154, 50, 205, "darkorchid3"],
[154, 192, 205, "lightblue3"],
[154, 205, 50, "yellow green", "yellowgreen", "yellow green", "yellowgreen"],
[154, 255, 154, "palegreen1"],
[155, 48, 255, "purple1"],
[155, 205, 155, "darkseagreen3"],
[156, 156, 156, "grey61"],
[158, 158, 158, "grey62"],
[159, 95, 159, "violetblue"],
[159, 121, 238, "mediumpurple2"],
[159, 182, 205, "slategray3"],
[160, 32, 240, "purple", "purple"],
[160, 82, 45, "sienna", "sienna", "sienna", "sienna"],
[161, 161, 161, "grey63"],
[162, 181, 205, "lightsteelblue3"],
[162, 205, 90, "darkolivegreen3"],
[163, 163, 163, "grey64"],
[164, 211, 238, "lightskyblue2"],
[165, 42, 42, "brown", "brown", "brown", "brown"],
[166, 42, 42, "brown"],
[166, 128, 100, "mediumwood"],
[166, 166, 166, "grey65"],
[168, 168, 168, "grey66"],
[169, 169, 169, "dark grey", "darkgray"],
[171, 130, 255, "mediumpurple1"],
[171, 171, 171, "grey67"],
[173, 173, 173, "grey68"],
[173, 216, 230, "light blue", "lightblue", "light blue", "lightblue"],
[173, 234, 234, "turquoise"],
[173, 255, 47, "green yellow", "greenyellow", "green yellow", "greenyellow"],
[174, 238, 238, "paleturquoise2"],
[175, 238, 238, "pale turquoise", "paleturquoise", "pale turquoise", "paleturquoise"],
[176, 48, 96, "maroon", "maroon"],
[176, 176, 176, "grey69"],
[176, 196, 222, "light steel blue", "lightsteelblue", "light steel blue", "lightsteelblue"],
[176, 224, 230, "powder blue", "powderblue", "powder blue", "powderblue"],
[176, 226, 255, "lightskyblue1"],
[178, 34, 34, "fire brick", "firebrick", "firebrick", "firebrick"],
[178, 58, 238, "darkorchid2"],
[178, 223, 238, "lightblue2"],
[179, 179, 179, "grey70"],
[179, 238, 58, "olivedrab2"],
[180, 82, 205, "mediumorchid3"],
[180, 205, 205, "lightcyan3"],
[180, 238, 180, "darkseagreen2"],
[181, 181, 181, "grey71"],
[184, 134, 11, "dark golden rod", "darkgoldenrod", "dark goldenrod", "darkgoldenrod"],
[184, 184, 184, "grey72"],
[185, 211, 238, "slategray2"],
[186, 85, 211, "medium orchid", "mediumorchid", "medium orchid", "mediumorchid"],
[186, 186, 186, "grey73"],
[187, 255, 255, "paleturquoise1"],
[188, 143, 143, "rosy brown", "rosybrown", "rosy brown", "pink"],
[188, 210, 238, "lightsteelblue2"],
[188, 238, 104, "darkolivegreen2"],
[189, 183, 107, "dark khaki", "darkkhaki", "dark khaki", "darkkhaki"],
[189, 189, 189, "grey74"],
[190, 190, 190, "gray", "grey"],
[191, 62, 255, "darkorchid1"],
[191, 191, 191, "grey75"],
[191, 239, 255, "lightblue1"],
[192, 0, 0, "freespeechred"],
[192, 192, 192, "silver", "silver", "silver"],
[192, 255, 62, "olivedrab1"],
[193, 205, 193, "honeydew 3", "honeydew3"],
[193, 205, 205, "azure3"],
[193, 255, 193, "darkseagreen1"],
[194, 194, 194, "grey76"],
[196, 196, 196, "grey77"],
[198, 226, 255, "slategray1"],
[199, 21, 133, "medium violet red", "mediumvioletred", "medium violet red", "mediumvioletred"],
[199, 199, 199, "grey78"],
[201, 201, 201, "grey79"],
[202, 225, 255, "lightsteelblue1"],
[202, 255, 112, "darkolivegreen1"],
[204, 50, 153, "violet red"],
[204, 204, 204, "grey80"],
[205, 0, 0, "red3"],
[205, 0, 205, "magenta3"],
[205, 16, 118, "deeppink3"],
[205, 38, 38, "firebrick3"],
[205, 41, 144, "maroon3"],
[205, 50, 120, "violetred3"],
[205, 51, 51, "brown3"],
[205, 55, 0, "orangered3"],
[205, 79, 57, "tomato3"],
[205, 85, 85, "indianred3"],
[205, 91, 69, "coral3"],
[205, 92, 92, "indian red", "indianred", "indian red", "indianred"],
[205, 96, 144, "hotpink3"],
[205, 102, 0, "darkorange3"],
[205, 102, 29, "chocolate3"],
[205, 104, 57, "sienna3"],
[205, 104, 137, "palevioletred3"],
[205, 105, 201, "orchid3"],
[205, 112, 84, "salmon3"],
[205, 127, 50, "mediumblue"],
[205, 129, 98, "lightsalmon3"],
[205, 133, 0, "orange3"],
[205, 133, 63, "peru", "peru", "peru", "tan3"],
[205, 140, 149, "lightpink3"],
[205, 145, 158, "pink3"],
[205, 149, 12, "darkgoldenrod3"],
[205, 150, 205, "plum3"],
[205, 155, 29, "goldenrod3"],
[205, 155, 155, "rosybrown3"],
[205, 170, 125, "burlywood3"],
[205, 173, 0, "gold3"],
[205, 175, 149, "peachpuff3"],
[205, 179, 139, "navajowhite3"],
[205, 181, 205, "thistle3"],
[205, 183, 158, "bisque 3", "bisque3"],
[205, 183, 181, "mistyrose3"],
[205, 186, 150, "wheat3"],
[205, 190, 112, "lightgoldenrod3"],
[205, 192, 176, "antiquewhite3"],
[205, 193, 197, "lavenderblush3"],
[205, 197, 191, "seashell 3", "seashell3"],
[205, 198, 115, "khaki3"],
[205, 200, 177, "cornsilk 3", "cornsilk3"],
[205, 201, 165, "lemonchiffon3"],
[205, 201, 201, "snow 3", "snow3"],
[205, 205, 0, "yellow3"],
[205, 205, 180, "lightyellow3"],
[205, 205, 193, "ivory 3", "ivory3"],
[205, 205, 205, "very light grey"],
[207, 207, 207, "grey81"],
[208, 32, 144, "violet red", "violetred"],
[209, 95, 238, "mediumorchid2"],
[209, 146, 117, "feldspar"],
[209, 209, 209, "grey82"],
[209, 238, 238, "lightcyan2"],
[210, 105, 30, "chocolate", "chocolate", "chocolate", "chocolate"],
[210, 180, 140, "tan", "tan", "tan", "tan"],
[211, 211, 211, "light grey", "lightgrey", "light gray", "lightgray"],
[212, 212, 212, "grey83"],
[214, 214, 214, "grey84"],
[216, 191, 216, "thistle", "thistle", "thistle", "thistle"],
[216, 216, 191, "wheat"],
[217, 217, 217, "grey85"],
[217, 217, 243, "quartz"],
[218, 112, 214, "orchid", "orchid", "orchid", "orchid"],
[218, 165, 32, "goldenrod", "goldenrod", "goldenrod", "goldenrod"],
[219, 112, 147, "pale violet red", "palevioletred", "pale violet red", "mediumvioletred"],
[219, 112, 219, "orchid"],
[219, 147, 112, "tan"],
[219, 219, 112, "goldenrod"],
[219, 219, 219, "grey86"],
[220, 20, 60, "crimson", "crimson"],
[220, 220, 220, "gainsboro", "gainsboro", "gainsboro", "gainsboro"],
[221, 160, 221, "plum", "plum", "plum", "plum"],
[222, 184, 135, "burly wood", "burlywood", "burlywood", "burlywood"],
[222, 222, 222, "grey87"],
[224, 102, 255, "mediumorchid1"],
[224, 224, 224, "grey88"],
[224, 238, 224, "honeydew2"],
[224, 238, 238, "azure2"],
[224, 255, 255, "light cyan", "lightcyan", "light cyan", "lightcyan1"],
[227, 91, 216, "freespeechmagenta"],
[227, 227, 227, "grey89"],
[229, 229, 229, "grey90"],
[230, 230, 250, "lavender", "lavender", "lavender", "lavender"],
[232, 232, 232, "grey91"],
[233, 150, 122, "dark salmon", "darksalmon", "dark salmon", "darksalmon"],
[234, 173, 234, "plum"],
[234, 234, 174, "mediumgoldenrod"],
[235, 199, 158, "newtan"],
[235, 235, 235, "grey92"],
[237, 237, 237, "grey93"],
[238, 0, 0, "red2"],
[238, 0, 238, "magenta2"],
[238, 18, 137, "deeppink2"],
[238, 44, 44, "firebrick2"],
[238, 48, 167, "maroon2"],
[238, 58, 140, "violetred2"],
[238, 59, 59, "brown2"],
[238, 64, 0, "orangered2"],
[238, 92, 66, "tomato2"],
[238, 99, 99, "indianred2"],
[238, 106, 80, "coral2"],
[238, 106, 167, "hotpink2"],
[238, 118, 0, "darkorange2"],
[238, 118, 33, "chocolate2"],
[238, 121, 66, "sienna2"],
[238, 121, 159, "palevioletred2"],
[238, 122, 233, "orchid2"],
[238, 130, 98, "salmon2"],
[238, 130, 238, "violet", "violet", "violet", "violet"],
[238, 149, 114, "lightsalmon2"],
[238, 154, 0, "orange2"],
[238, 154, 73, "tan2"],
[238, 162, 173, "lightpink2"],
[238, 169, 184, "pink2"],
[238, 173, 14, "darkgoldenrod2"],
[238, 174, 238, "plum2"],
[238, 180, 34, "goldenrod2"],
[238, 180, 180, "rosybrown2"],
[238, 197, 145, "burlywood2"],
[238, 201, 0, "gold2"],
[238, 203, 173, "peachpuff2"],
[238, 207, 161, "navajowhite2"],
[238, 210, 238, "thistle2"],
[238, 213, 183, "bisque 2", "bisque2"],
[238, 213, 210, "mistyrose2"],
[238, 216, 174, "wheat2"],
[238, 220, 130, "lightgoldenrod2"],
[238, 221, 130, "light goldenrod", "lightgoldenrod"],
[238, 223, 204, "antiquewhite2"],
[238, 224, 229, "lavenderblush2"],
[238, 229, 222, "seashell 2", "seashell2"],
[238, 230, 133, "khaki2"],
[238, 232, 170, "pale golden rod", "palegoldenrod", "pale goldenrod", "palegoldenrod"],
[238, 232, 205, "cornsilk 2", "cornsilk2"],
[238, 233, 191, "lemonchiffon2"],
[238, 233, 233, "snow 2", "snow2"],
[238, 238, 0, "yellow2"],
[238, 238, 209, "lightyellow2"],
[238, 238, 224, "ivory 2", "ivory2"],
[240, 128, 128, "light coral", "lightcoral", "light coral", "lightcoral"],
[240, 230, 140, "khaki", "khaki", "khaki", "khaki"],
[240, 240, 230, "linen"],
[240, 240, 240, "grey94"],
[240, 248, 255, "alice blue", "aliceblue", "alice blue", "aliceblue"],
[240, 255, 240, "honey dew", "honeydew", "honeydew", "honeydew1"],
[240, 255, 255, "azure", "azure", "azure", "azure1"],
[242, 242, 242, "grey95"],
[244, 164, 96, "sandy brown", "sandybrown", "sandy brown", "sandybrown"],
[244, 238, 224, "honeydew 2"],
[245, 204, 176, "maroon"],
[245, 222, 179, "wheat", "wheat", "wheat", "wheat"],
[245, 245, 220, "beige", "beige", "beige", "beige"],
[245, 245, 245, "white smoke", "whitesmoke", "white smoke", "whitesmoke"],
[245, 255, 250, "mint cream", "mintcream", "mint cream", "mintcream"],
[247, 247, 247, "grey97"],
[248, 248, 255, "ghost white", "ghostwhite", "ghost white", "ghostwhite"],
[250, 128, 114, "salmon", "salmon", "salmon", "salmon"],
[250, 235, 215, "antique white", "antiquewhite", "antique white", "antiquewhite"],
[250, 240, 230, "linen", "linen", "linen"],
[250, 250, 210, "light goldenrod yellow", "lightgoldenrodyellow", "light goldenrod yellow", "lightgoldenrodyellow"],
[250, 250, 250, "grey98"],
[252, 252, 252, "grey99"],
[253, 245, 230, "oldlace", "oldlace", "old lace", "oldlace"],
[255, 0, 0, "red", "red", "red", "red1"],
[255, 0, 255, "magenta", "magenta", "magenta1"],
[255, 20, 147, "deep pink", "deeppink", "deep pink", "deeppink1"],
[255, 28, 174, "spicypink"],
[255, 36, 0, "orange red"],
[255, 48, 48, "firebrick1"],
[255, 52, 179, "maroon1"],
[255, 62, 150, "violetred1"],
[255, 64, 64, "brown1"],
[255, 69, 0, "orange red", "orangered", "orange red", "orangered1"],
[255, 99, 71, "tomato", "tomato", "tomato", "tomato1"],
[255, 105, 180, "hot pink", "hotpink", "hot pink", "hotpink"],
[255, 106, 106, "indianred1"],
[255, 110, 180, "hotpink1"],
[255, 110, 199, "neonpink"],
[255, 114, 86, "coral1"],
[255, 127, 0, "orange"],
[255, 127, 36, "chocolate1"],
[255, 127, 80, "coral", "coral", "coral", "coral"],
[255, 130, 71, "sienna1"],
[255, 130, 171, "palevioletred1"],
[255, 131, 250, "orchid1"],
[255, 140, 0, "dark orange", "darkorange", "dark orange", "darkorange"],
[255, 140, 105, "salmon1"],
[255, 160, 122, "light salmon", "lightsalmon", "light salmon", "lightsalmon1"],
[255, 165, 0, "orange", "orange", "orange", "orange1"],
[255, 165, 79, "tan1"],
[255, 174, 185, "lightpink1"],
[255, 181, 197, "pink1"],
[255, 182, 193, "light pink", "lightpink", "light pink", "lightpink"],
[255, 185, 15, "darkgoldenrod1"],
[255, 187, 255, "plum1"],
[255, 192, 203, "pink", "pink", "pink", "pink"],
[255, 193, 37, "goldenrod1"],
[255, 193, 193, "rosybrown1"],
[255, 211, 155, "burlywood1"],
[255, 215, 0, "gold", "gold", "gold", "gold1"],
[255, 218, 185, "peach puff", "peachpuff", "peach puff", "peachpuff1"],
[255, 222, 173, "navajo white", "navajowhite", "navajo white", "navajowhite1"],
[255, 225, 255, "thistle1"],
[255, 228, 181, "moccasin", "moccasin", "moccasin", "moccasin"],
[255, 228, 196, "bisque", "bisque", "bisque", "bisque1"],
[255, 228, 225, "misty rose", "mistyrose", "misty rose", "mistyrose1"],
[255, 231, 186, "wheat1"],
[255, 235, 205, "blanched almond", "blanchedalmond", "blanched almond", "blanchedalmond"],
[255, 236, 139, "lightgoldenrod1"],
[255, 239, 213, "papaya whip", "papayawhip", "papaya whip", "papayawhip"],
[255, 239, 219, "antiquewhite1"],
[255, 240, 245, "lavender blush", "lavenderblush", "lavender blush", "lavenderblush1"],
[255, 245, 238, "sea shell", "seashell", "seashell", "seashell1"],
[255, 246, 143, "khaki1"],
[255, 248, 220, "cornsilk", "cornsilk", "cornsilk", "cornsilk1"],
[255, 250, 205, "lemon chiffon", "lemonchiffon", "lemon chiffon", "lemonchiffon1"],
[255, 250, 240, "floral white", "floralwhite", "floral white", "floralwhite"],
[255, 250, 250, "snow", "snow", "snow", "snow1"],
[255, 255, 0, "yellow", "yellow", "yellow", "yellow1"],
[255, 255, 224, "light yellow", "lightyellow", "light yellow", "lightyellow1"],
[255, 255, 240, "ivory", "ivory", "ivory", "ivory1"],
[255, 255, 255, "white", "white", "white", "white"]].each do |raw|
  rgb = sprintf("#%02x%02x%02x", raw[0], raw[1], raw[2])
  (3..7).each do |i|
    if raw[i]
      @colors[raw[i]] = rgb
    end
  end
end

def find_color(string)
  potentials = {}
  @colors.each do |key, value|
    if ! string.index(key).nil? &&
      (string[string.index(key) - 1] =~ /\W/ || string[string.index(key) - 1].nil? ) && # character before phrase is empty, OR
      (string[string.index(key) + key.length] =~ /\W/ || string[string.index(key) + key.length].nil? ) # character after phrase is non-word character
      potentials[key] = value
    end
  end
  if potentials.any?
    puts potentials.keys
    longest_key = potentials.keys.sort_by {|key| key.length }.last
    return potentials[longest_key], potentials
  else
    return nil
  end
end

def tweet_received(tweet)
  if tweet[:text]
    text = ProfanityFilter::Base.clean(tweet[:text], 'hollow')
    user = (! tweet[:user].nil?) ? tweet[:user][:screen_name] : "???"
    color, phrase = find_color(tweet[:text]) || ['#FFFFFF']
    puts "Received tweet from #{user}, color #{color}: #{text}"
    @tweet_queue.push(
      :message => {:user => user, :text => text, :color => color, :type => "tweet"}.to_json,
      :color => color,
      :phrase => phrase
    )
  end
end

def background_received(tweet)
  if tweet[:text] && rand(100) < 10.0
    text = ProfanityFilter::Base.clean(tweet[:text], 'hollow')
    user = (! tweet[:user].nil?) ? tweet[:user][:screen_name] : "???"
    @background_queue.push(:message => {:user => user, :text => text, :type => "background"}.to_json)
  end
end


class Arduino
  @color = "#111111"
  # @connection = Net::Telnet::new("Host" => $CONFIG["arduino"]["host"], "Port" => $CONFIG["arduino"]["port"])

  class << self
    attr_accessor :color
    attr_reader :connection

    def send_color
      # Arduino.connection.puts Arduino.color
    end

    def random_rgb
      # sprintf("#%02x%02x%02x", rand(255), rand(255), rand(255))
      ["#0000FF",
       "#FF0000",
       "#00FF00",
       "#FFFF00",
       "#FF00FF",
       "#00FFFF",
       "#FFFFFF"
      ][rand(7)]
    end
  end
end

# Main run loop
EventMachine.run do
  @tweet_queue = EM::Queue.new
  @background_queue = EM::Queue.new
  @color_queue = EM::Queue.new
  @tweet_parser = Yajl::Parser.new(:symbolize_keys => true)
  @tweet_parser.on_parse_complete = method(:tweet_received)
  @background_parser = Yajl::Parser.new(:symbolize_keys => true)
  @background_parser.on_parse_complete = method(:background_received)

  EventMachine::PeriodicTimer.new($CONFIG["timing"]["colors"]) do
    Arduino.send_color
  end

  EventMachine::WebSocket.start(:host => "localhost", :port => 8080) do |ws|
    ws.onopen do
      puts "WebSocket connection open"
    end
    EventMachine::PeriodicTimer.new($CONFIG["timing"]["tweets"]) do
      @tweet_queue.pop do |msg|
        ws.send msg[:message].force_encoding('UTF-8')
        Arduino.color = msg[:color]
      end
    end
    EventMachine::PeriodicTimer.new($CONFIG["timing"]["backgrounds"]) do
      @background_queue.pop {|msg| ws.send msg[:message].force_encoding('UTF-8')}
    end
    ws.onmessage do |msg|
      puts "Received message: #{msg}"
    end
    ws.onclose do
      puts "Connection closed"
    end
  end

  background_connection = EventMachine::HttpRequest.new(
    'https://stream.twitter.com/1/statuses/filter.json').get(
      :head => {'authorization' => ["creativeembassy", "passsss"]},
      :query => {:track => "2012,happy new year,happy new years eve"}
    )
  background_connection.stream do |chunk|
    @background_parser << chunk
  end
  background_connection.errback { puts "oops, error on background connection" }
  background_connection.disconnect { puts "oops, dropped background connection?" }

  tweet_connection = EventMachine::HttpRequest.new(
    'https://stream.twitter.com/1/statuses/filter.json').get(
      :head => {'authorization' => [$CONFIG["twitter"]["username"], $CONFIG["twitter"]["password"]]},
      # :query => {:follow => "440496972"} # Follow Inukshuk2012
      # :query => {:locations => "39.79,-80.35,41.92,-75.01"} # Pennsylvania
      :query => {:track => "innoblue,firstnight2012,first night 2012"} # Innoblue & First Night
    )
  tweet_connection.stream do |chunk|
    @tweet_parser << chunk
  end
  tweet_connection.errback { puts "oops, error on twitter connection" }
  tweet_connection.disconnect { puts "oops, dropped twitter connection?" }

  Client.run!({:port => 3000})
end
