export module ColorHelper {
    enum Color {
        lightBlue = 0,
        blue = 1,
        darkBlue = 2,
        teal = 3,
        lightGreen = 4,
        green = 5,
        darkGreen = 6,
        lightPink = 7,
        pink = 8,
        magenta = 9,
        purple = 10,
        black = 11,
        orange = 12,
        red = 13,
        darkRed = 14,
    }

    const COLOR_SWATCHES_LOOKUP: Color[] = [
        Color.lightGreen,
        Color.lightBlue,
        Color.lightPink,
        Color.green,
        Color.darkGreen,
        Color.pink,
        Color.magenta,
        Color.purple,
        Color.black,
        Color.teal,
        Color.blue,
        Color.darkBlue,
        Color.orange,
        Color.darkRed
    ];
    const COLOR_SWATCHES_NUM_ENTRIES = COLOR_SWATCHES_LOOKUP.length;

    export function HexCodeFromText(displayName: string | undefined): string {
        let color = getColorFromText(displayName);
        return colorToHexCode(color);
    }

    function colorToHexCode(color: Color): string {
        switch (color) {
            case Color.lightBlue:
                return '#6BA5E7';
            case Color.blue:
                return '#2D89EF';
            case Color.darkBlue:
                return '#2B5797';
            case Color.teal:
                return '#00ABA9';
            case Color.lightGreen:
                return '#99B433';
            case Color.green:
                return '#00A300';
            case Color.darkGreen:
                return '#1E7145';
            case Color.lightPink:
                return '#E773BD';
            case Color.pink:
                return '#FF0097';
            case Color.magenta:
                return ' #7E3878';
            case Color.purple:
                return '#603CBA';
            case Color.black:
                return '#1D1D1D';
            case Color.orange:
                return '#DA532C';
            case Color.red:
                return '#EE1111';
            case Color.darkRed:
                return '#B91D47';
        }
        return 'transparent';
    }

    function getColorFromText(text: string | undefined): Color {
        let color = Color.blue;
        if (!text) {
            return color;
        }

        let hashCode = 0;
        for (let iLen: number = text.length - 1; iLen >= 0; iLen--) {
            const ch: number = text.charCodeAt(iLen);
            const shift: number = iLen % 8;
            // tslint:disable-next-line:no-bitwise
            hashCode ^= (ch << shift) + (ch >> (8 - shift));
        }

        color = COLOR_SWATCHES_LOOKUP[hashCode % COLOR_SWATCHES_NUM_ENTRIES];
        return color;
    }
}