import math

from PIL import Image, ImageDraw

TOP = (0x66, 0x73, 0xFF)   # #6673FF
BOTTOM = (0x2E, 0x45, 0xF5)  # #2E45F5
WHITE = (255, 255, 255)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def vertical_gradient(size, top, bottom):
    w, h = size
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        col = lerp(top, bottom, y / (h - 1))
        for x in range(w):
            px[x, y] = col
    return img


def rounded_rect_mask(size, radius):
    """Return an L-mode mask with a rounded rectangle filled white."""
    w, h = size
    mask = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, w - 1, h - 1], radius=radius, fill=255)
    return mask


def apply_rounded_mask(img, radius):
    mask = rounded_rect_mask(img.size, radius)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    layer.paste(img, (0, 0), mask)
    return layer


def ss_draw(draw_fn, size, scale=4):
    """Render draw_fn at a higher resolution then downscale (anti-aliasing)."""
    big = Image.new("RGBA", (size[0] * scale, size[1] * scale), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    draw_fn(d, size[0] * scale)
    return big.resize(size, Image.LANCZOS)


def play_mark_draw(d, s):
    """White play triangle + soft ring fitted in an s x s canvas."""
    cx = s / 2
    # ring
    ring_r = s * 0.24
    ring_w = int(s * 0.028)
    d.ellipse(
        [cx - ring_r, cx - ring_r, cx + ring_r, cx + ring_r],
        outline=(255, 255, 255, 150),
        width=ring_w,
    )
    # triangle
    tip = (cx + s * 0.16, cx)
    tl = (cx - s * 0.10, cx - s * 0.13)
    bl = (cx - s * 0.10, cx + s * 0.13)
    d.polygon([tip, tl, bl], fill=WHITE)


def artwork(size):
    """Full logo artwork: gradient rounded square + play mark."""
    grad = vertical_gradient(size, TOP, BOTTOM)
    rounded = apply_rounded_mask(grad, int(size[0] * 0.18))
    mark = ss_draw(play_mark_draw, size)
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    out.alpha_composite(rounded)
    out.alpha_composite(mark)
    return out


def paste_centered_fit(canvas_size, art, factor):
    """Paste art scaled to `factor` of canvas size, centered."""
    out = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    a = art.resize((int(canvas_size[0] * factor), int(canvas_size[1] * factor)), Image.LANCZOS)
    x = (canvas_size[0] - a.size[0]) // 2
    y = (canvas_size[1] - a.size[1]) // 2
    out.alpha_composite(a, (x, y))
    return out


def run():
    logo = artwork((1024, 1024))
    logo.save("assets/images/logo.png")

    # Adaptive-icon foreground: artwork kept inside the safe zone (~66%).
    fg = paste_centered_fit((1024, 1024), logo, 0.66)
    fg.save("assets/images/logo_foreground.png")

    # Splash logo: play mark only on transparent, ~50% coverage.
    splash = ss_draw(play_mark_draw, (240, 240))
    # fade from full white at the ring outwards would blend on solid bg nicely
    splash.save("android/app/src/main/res/drawable-nodpi/splash_logo.png")

    print("generated logo assets")


if __name__ == "__main__":
    run()