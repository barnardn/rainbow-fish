


var RainbowFishExtractor = {

    pencilData : [],

    hexToRgb : function (hex) {
        // Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
        var shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
        hex = hex.replace(shorthandRegex, function(m, r, g, b) {
            return r + r + g + g + b + b;
        });

        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : null;
    },


    extractPrismacolor :  function () {
        var idx = 0;

        while (obj = document.getElementById("color" + idx)) {
            var pencil = {};

            var listItem = obj.children[0];

            pencil.name = listItem.getElementsByTagName('h3')[0].textContent;
            pencil.identifier = listItem.getElementsByTagName('h4')[0].textContent;
            if (pencil.identifier.length == 0) {
                pencil.identifier = pencil.name;
            }
            pencil.normalizedId = pencil.identifier.split(' ').join('').toLowerCase();

            var rgbItem = listItem.getElementsByTagName('li')[0];
            pencil.color = rgbItem.textContent.split(':')[1].trim()

            this.pencilData[idx] = pencil;

            idx++;
        }
        this.showPencils()
    },

    extractDerwent : function () {

        var colorInfoDivs = document.getElementsByClassName('colourChartWrapper')

        for (var i in colorInfoDivs) {

            var pencil = {}

            var colorDiv = colorInfoDivs[i]

            if (typeof colorDiv.getElementsByClassName === 'undefined') {
                continue;
            }

            var nameObj = colorDiv.getElementsByClassName('theColourTitleLabel')[0]
            var numberObj = colorDiv.getElementsByClassName('theColourNumber')[0]
            var colorPanel = colorDiv.getElementsByClassName('colourPanel')[0]

            var name = nameObj.textContent.trim();

            pencil.name = name.split(' ').slice(1).join(' ')
            pencil.identifier = numberObj.textContent.trim()
            pencil.normalizedId = numberObj.textContent.trim().toLowerCase()

            var colorText = colorPanel.getAttributeNode('style').textContent

            var colorRegex = /.+:#(.+);/
            var matches = colorRegex.exec(colorText)

            console.log(matches[1]);

            var rgbValue = this.hexToRgb(matches[1])
            pencil.color = rgbValue.r + "," + rgbValue.g + "," + rgbValue.b;

            this.pencilData[i] = pencil

        }
        this.showPencils()
    },

    extractFaberCastell: function () {

        var paletteInfo = document.getElementsByClassName('color-palette')

        for (var i in paletteInfo[0].children) {
            var pencil = {}

            if (typeof paletteInfo[0].children[i].getElementsByClassName === 'undefined') {
                continue;
            }

            var colorNodes = paletteInfo[0].children[i].getElementsByClassName('color')
            var colorStyle = colorNodes[0].children[0].getAttributeNode('style').textContent

            var colorRegex = /.+:#(.+)$/
            var matches = colorRegex.exec(colorStyle)

            var rgbValue = this.hexToRgb(matches[1])
            pencil.color = rgbValue.r + "," + rgbValue.g + "," + rgbValue.b;

            var textNode = paletteInfo[0].children[i].getElementsByClassName('text')[0]

            var textInfo = textNode.getElementsByTagName('p')

            pencil.identifier = textInfo[0].textContent.trim()
            pencil.normalizedId = pencil.identifier

            var name = textInfo[1].textContent.trim()
            pencil.name = name.charAt(0).toUpperCase() + name.slice(1)

            this.pencilData[i] = pencil

        }
        this.showPencils()
    },


    showPencils : function () {

        str = "[\n";

        for (var i in this.pencilData) {
            var p = this.pencilData[i]
            str += "\t{";
            str += '\t\t "name" : "'  + p.name + '"';
            str += '\t\t ,"identifier"  : "' + p.identifier + '"';
            str += '\t\t ,"normalizedId" : "' + p.normalizedId + '"';
            str += '\t\t ,"color": "' + p.color + '"';
            str += "\t}";
            if (i == this.pencilData.length - 1) {
                str += "\n";
            } else {
                str += ",\n";
            }
        }
        str += "]\n";
        console.log(str);

    }

};
