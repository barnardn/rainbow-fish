


var RainbowFishExtractor = {

    pencilData : [],

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

    extractDerwent : function () {




    }



};
