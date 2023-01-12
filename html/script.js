var categoryVehicleSelected = "muscle";
var vehicleSelected = {};

var dataVehicles = [];
var handlingVehicle = [];

var selectedColor = "primary";



window.addEventListener('message', function(event) {
    var data = event.data;

    if (event.data.type == "display") {

        $("body").fadeIn();

        document.getElementById("top-menu").innerHTML = '<a href="#all" onclick="menuVehicle(event)" value="all" class="selected">all</a>';       

        for(var [key,value] of Object.entries(data.data)){   

            $('.top-menu').append(`
                <a href="#` + key + `" onclick="menuVehicle(event)" value="` + key + `">` + key + `</a>            
            `);

            for(var [k,v] of Object.entries(value)){
                dataVehicles.push(v);          
            }             
        }
        Dealership.Open(dataVehicles);

    }

    if (event.data.type == "hide") {
        $("body").fadeOut();
    }
    
    if (event.data.type == "menu") {

        for(var [k,v] of Object.entries(data.data)){
            dataVehicles.push(v);          
        }    
        Dealership.Open(dataVehicles);
    }

    if (event.data.type == "notify") {       
        var data = event.data;

        $("#messagePopup").css("background-color","rgb(252, 18, 18)");      

        $("#messagePopup").fadeIn(500);      
        
        $('#messagePopup').append(`

        <span>`+ data.message +`</span>    
        
        `)
        
        setTimeout(function(){ $("#messagePopup").fadeOut(500);         document.getElementById("messagePopup").innerHTML = ''; }, 3000);

    }

    if (event.data.type == "updateVehicleInfos") {
        var data = event.data;
        handlingVehicle = data.data;
        
        vehicleSelected.sale = vehicleSelected.sale*1000
        var priceVehicle = vehicleSelected.sale.toLocaleString('en-US');

        $('#contentVehicle').append(`
                    <div class="row spacebetween">
                        <span class="priceVehicle">$`+ priceVehicle +`</span>
                    </div>     

                    <div class="column spacebetween info">
                        <span class="title">Handling</span>
                        <div class="bar">
                            <span class="percent" style="width:`+Math.ceil(10*handlingVehicle.traction*1.6)+`%"></span>
                        </div>
                     
                    </div>

                    <div class="column spacebetween info">
                        <span class="title">Top Speed</span>
                        <div class="bar">
                            <span class="percent" style="width:`+Math.ceil(handlingVehicle.maxSpeed*1.4)+`%"></span>
                        </div>

                    </div>

                    <div class="column spacebetween info">
                        <span class="title">Acceleration</span>
                        <div class="bar">
                            <span class="percent" style="width:`+Math.ceil(100*handlingVehicle.acceleration)+`%"></span>
                        </div>
                    </div>

                    <div class="column spacebetween info">
                        <span class="title">Breaking</span>
                        <div class="bar">
                            <span class="percent" style="width:`+Math.ceil(100*handlingVehicle.breaking)+`%"></span>
                        </div>
                    </div>         
                `);
    }
});

$(document).ready(function() {
    $('.upper-bottom-container').on('afterChange', function(event, slick, currentSlide) {
        
        $('.button-container').appendTo(currentSlide);
    });
});

function menuVehicle(event) {
    var div = $(event.target).parent().find('.selected');
        
    $(div).removeClass('selected');

    $(event.currentTarget).addClass('selected');

    categoryVehicleSelected = $(event.currentTarget).attr('value');

    document.getElementById("nameBrand").innerHTML = '';
    document.getElementById("contentVehicle").innerHTML = '';              
    document.getElementById("vehiclebrand").innerHTML = '';
    document.getElementById("carouselCars").innerHTML = '';

    dataVehicles = [];
    
    $.post('https://cad-tuners/menuSelected', JSON.stringify({menuId: categoryVehicleSelected.toLowerCase()}));
}

function openModalMenu(){    
    document.getElementById("closemenu").innerHTML = '';
    $("body").fadeIn();
    $('.modal').css("display","flex");

    $('#closemenu').append(`
        <div class="background-circle"></div>
        <div class="modal-content">
            <p class="title">Purchase confirmation:</p>
            <p class="vehicle">Vehicle</p>         

            <p>Brand: <span class="brand">`+vehicleSelected.brand+`</span></p>
            <p>Model: <span class="model">`+vehicleSelected.modelcar+`</span></p>
        </div>

        <div class="modal-footer">
            <div class="modal-price">
                <p class='price sale'>$ `+ vehicleSelected.sale/1000+` k</p>
                <p class='price discount'>$ `+ parseFloat(vehicleSelected.sale/1000 * 1.1).toFixed(3)+` k</p>                  
            </div>
            <div class="modal-buttons">                
                <div>
                    <span>Cancel</span>
                    <button href="#!" id="card" class="modal-money button" onclick="cancelVehicle()">X</button>
                </div>
            </div>
        </div>
    `);
}

function cancelVehicle() {
    $('.modal').css("display","none");
}

var scrollAmount = 0

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESC
            $.post('https://cad-tuners/Close');
            $('body').css("display","none");
            document.getElementById("top-menu").innerHTML = '';
            break;
        case 9: // TAB
            break;
        case 17: // TAB
            break;
        case 68: // LEFT A
            $.post('https://cad-tuners/rotate', JSON.stringify({key: "left"}))
            break;            
        case 65: // RIGHT D
            $.post('https://cad-tuners/rotate', JSON.stringify({key: "right"}))
            break;
        case 39: // RIGHT
            scrollAmount = scrollAmount + 200
            $('.carousel-cars').animate({scrollLeft:scrollAmount}, 'fast');
            break;
        case 37: // LEFT
            scrollAmount = scrollAmount - 200
            $('.carousel-cars').animate({scrollLeft:scrollAmount}, 'fast');
            break;
    }
});

document.addEventListener('wheel', function(event) {
    if (event.deltaY < 0) { // Scroll Up
        scrollAmount = scrollAmount - 200
        $('.carousel-cars').animate({scrollLeft:scrollAmount}, 'fast');
    }
    else if (event.deltaY > 0) { // Scroll Down
        scrollAmount = scrollAmount + 200
        $('.carousel-cars').animate({scrollLeft:scrollAmount}, 'fast');
    }
});

$(document).on('keydown', function(ev) {
    var input = $(ev.target);
    var num = input.hasClass('input-number');
    var _key = false;
    if (ev.which == 68) {
        if (num === false) {
            _key = "left"
        }
        else if (num) {
            input.val(parseInt(input.val()) + 1)
            inputChange(input,true)
        }
    }
    if (ev.which == 65) {
        if (num === false) {
            _key = "right"
        }
        else if (num) {
            input.val(parseInt(input.val()) - 1)
            inputChange(input,false)
        }
    }

    if (_key) {
        $.post('https://cad-tuners/rotate', JSON.stringify({key: _key}))
    }

});

$(document).on('mousedown', ".item-cars", function(event){

    switch(event.which) {        
        case 3:          
            break;
        case 1:

            var div = $(this).parent().find('.selectedVehicle');        
            $(div).removeClass('selectedVehicle');

            var classList = $(event.currentTarget).attr('class').split(/\s+/);
            var itemDisabled = false;

            $.each(classList, function(index, item) {
                if (item === 'disable') {        
                    itemDisabled = true;
                }
            });

            if(!itemDisabled) {
                $(event.currentTarget).addClass('selectedVehicle');         

                $('#colorPicker').css("display","flex");
                
                var dataCar = $(event.currentTarget).find('.specification').find('span');

                $('.modal').css("display","none");

                document.getElementById("nameBrand").innerHTML = '';                
                document.getElementById("vehiclebrand").innerHTML = '';
                document.getElementById("contentVehicle").innerHTML = '';
                                          
                $('#nameBrand').append(`               
                    <span id="vehicle_name">`+dataCar[1].outerText+`</span> 
                    <span id="vehicle_line"></span> 
                    <span id="vehicle_brand">`+dataCar[0].outerText+`</span> 
                `);
                
                $(".changeVehicleColor").css("display","block");

                vehicleSelected = {brand: dataCar[0].outerText, modelcar: dataCar[9].outerText, sale: dataCar[7].outerText/1000, name: dataCar[1].outerText }                
                
                $.post("https://cad-tuners/SpawnVehicle", JSON.stringify({ modelcar: dataCar[9].outerText, price: dataCar[7].outerText }));
            }
        break;
    }
});

(() => {
    Dealership = {};

    Dealership.Open = function(data) { 
        for(i = 0; i < (data.length); i++) {   

            var modelUper = data[i].model;                
            
            if (data[i].qtd < 1) {
                $(".carousel-cars").append(`
                <div class="item-cars"> 
                    <div class="col-lg-3 col-md-6 "> 
                        <div class="specification" style="opacity:0.0; position:absolute;">
                            <span id="brand">`+ data[i].brand +`</span>
                            <span id="name">`+ data[i].name +`</span>
                            <span id="fabrication">`+ data[i].fabrication +`</span>
                            <span id="handling">`+ data[i].handling +`</span>
                            <span id="topspeed">`+ data[i].topspeed +`</span>
                            <span id="power">`+ data[i].power +`</span>
                            <span id="breaking">`+ data[i].breaking +`</span>
                            <span id="price">`+ data[i].price +`</span>
                            <span id="qtd">`+ data[i].qtd +`</span>
                            <span id="model">`+ data[i].model +`</span>
                            <span id="category">`+ data[i].category +`</span>
                        </div>        
                        <div class="img-fluid" style="background-image: url(../imgs/` + modelUper.toUpperCase() +`.png);"> <span class="exibeName">`+ data[i].name +`</span></div>
                    </div>
                </div>`);
            }                 
            else if (data[i].qtd > 0) {
                $(".carousel-cars").append(`
                <div class="item-cars" >
                    <div class="col-lg-3 col-md-6 ">
                        <div class="specification" style="opacity:0.0; position:absolute;">
                            <span id="brand">`+ data[i].brand +`</span>
                            <span id="name">`+ data[i].name +`</span>
                            <span id="fabrication">`+ data[i].fabrication +`</span>
                            <span id="handling">`+ data[i].handling +`</span>
                            <span id="topspeed">`+ data[i].topspeed +`</span>
                            <span id="power">`+ data[i].power +`</span>
                            <span id="breaking">`+ data[i].breaking +`</span>
                            <span id="price">`+ data[i].price +`</span>
                            <span id="qtd">`+ data[i].qtd +`</span>
                            <span id="model">`+ data[i].model +`</span>
                            <span id="category">`+ data[i].category +`</span>
                        </div>
                       
                        <div class="img-fluid" style="background-image:  url(../html/images/car-bg.png);"> <span class="exibeName">`+ data[i].name +`</span></div>
                    </div>
                </div>`);
            }            
        }     
    }
    Dealership.Open(dataVehicles);
})();



function openOption(option){
    pickr.show();
}


function setVehicleColorRGB(R,G,B){
    
    if (selectedColor == 'primary'){
        $.post("https://cad-tuners/RGBVehicle", JSON.stringify({primary: true, R: R, G: G, B: B}));
    } else {
        $.post("https://cad-tuners/RGBVehicle", JSON.stringify({primary: false, R: R, G: G, B: B}));
    }
}
                        
