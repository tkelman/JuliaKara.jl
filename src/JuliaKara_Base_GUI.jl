module JuliaKara_Base_GUI
using Gtk,Gtk.ShortNames, Graphics
using Cairo

export
    Grid,
    grid_draw,
    world_init,
    symbol_image,
    cover_field

res_path = joinpath(@__DIR__,"..","res","icons")
icons = Dict(
    :kara => read_from_png(joinpath(res_path,"bugnorth.png")),
    :tree => read_from_png(joinpath(res_path,"object_tree.png")),
    :mushroom => read_from_png(joinpath(res_path,"object_mushroom.png")),
    :leaf => read_from_png(joinpath(res_path,"object_leaf.png"))
)

struct Grid{Tx<:Real,Ty<:Real,Tw<:Real,Th<:Real}
    x::Tx
    y::Ty
    width::Tw
    height::Th
    xe::Int
    ye::Int
end

function grid_draw(gr::Grid,ctx::Gtk.CairoContext)
    new_path(ctx)
    move_to(ctx,gr.x,gr.y)
    set_source_rgb(ctx,0,0,0)
    for x in linspace(gr.x,gr.x+gr.width,gr.xe+1)
        move_to(ctx,x,gr.y+gr.height)
        rel_line_to(ctx,0,-gr.height)
    end
    for y in linspace(gr.y,gr.y+gr.height,gr.ye+1)
        move_to(ctx,gr.x,y)
        rel_line_to(ctx,gr.width,0)
    end
    stroke(ctx)
end

function grid_coordinate_real(gr::Grid,x::Int,y::Int)
    gr.x + gr.width/gr.xe*(x-1),
    gr.y + gr.height/gr.ye*(gr.ye-y)
end

function grid_coordinate_virt(gr::Grid,xr::Float64,yr::Float64)
    Int(floor((xr-gr.x)*gr.xe/gr.width+1)),
    Int(ceil(gr.ye - (yr-gr.y)*gr.ye/gr.height))
end


function world_init(title::AbstractString)
    b = GtkBuilder(filename=joinpath(@__DIR__,"layout.glade"))
    c = @Canvas()
    fc = b["frame_canvas"]
    push!(fc,c)
    win = b["win_main"]
    showall(win)
    return b,win,c
end

function cover_field(gr::Grid,ctx::Gtk.CairoContext,x::Int,y::Int)
    wi = gr.width/gr.xe
    hi = gr.height/gr.ye
    xr,yr = grid_coordinate_real(gr,x,y)
    set_source_rgb(ctx,0.85,0.85,0.85)
    rectangle(ctx,xr,yr,wi,hi)
    fill(ctx)
    set_source_rgb(ctx,0.0,0.0,0.0)
    rectangle(ctx,xr,yr,wi,hi)
    stroke(ctx)
end

function symbol_image(gr::Grid,ctx::Gtk.CairoContext,x::Int,y::Int,angle::T,image::Symbol) where T <: Real
    cairo_matrix = get_matrix(ctx)
    wi = gr.width/gr.xe
    hi = gr.height/gr.ye
    xr,yr = grid_coordinate_real(gr,x,y)
    img = icons[image]
    translate(ctx,xr,yr)
    translate(ctx,wi/2,hi/2)
    rotate(ctx,-angle)
    translate(ctx,-wi/2,-hi/2)
    scale(ctx,wi/img.width,hi/img.height)
    set_source_surface(ctx,img,0,0)
    paint(ctx)
    set_matrix(ctx,cairo_matrix)
end

end
