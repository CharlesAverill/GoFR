from PIL import Image

def convert_to_ocaml_format(image_path):
    image = Image.open(image_path)
    width, height = image.size

    ocaml_format = "open Graphics\n\n"

    for y in range(height):
        row = image.getpixel((0, y))
        ocaml_format += f"{'let' if y == 0 else 'and'} row{y} = [|"
        for x in range(width):
            try:
                r, g, b = image.getpixel((x, y))
                a = 1
            except ValueError as e:
                r, g, b, a = image.getpixel((x, y))
            color = f"0x{r:02x}{g:02x}{b:02x}"
            ocaml_format += f"{color}; "
        ocaml_format += "|]\n"

    ocaml_format += f"\nlet {image_path[:image_path.index('.')]} () =\n  make_image\n    [|"
    for y in range(height):
        ocaml_format += f"\n      row{y};"
    ocaml_format += "\n    |]\n"

    return ocaml_format

if __name__ == "__main__":
    import sys
    image_path = sys.argv[1] 
    ocaml_code = convert_to_ocaml_format(image_path)
    print(ocaml_code)
