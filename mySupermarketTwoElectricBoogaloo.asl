// Agent mySupermarket in project DomesticRobot.mas2j

/* Initial beliefs and rules */

// Identificador de la última orden entregada
last_order_id(1).
stockSuper(beer, 200, 2).

/* Initial goals */

!deliverBeer.

/* Plans */

+!deliverBeer : last_order_id(N) & orderFrom(Ag, Qtd) <-
	OrderId = N + 1;
    -+last_order_id(OrderId);
    deliver(Product,Qtd);
    .send(Ag, tell, delivered(Product, Qtd, OrderId));
	-orderFrom(Ag, Qtd);
	!deliverBeer.
	
+!deliverBeer <- !deliverBeer.
	
// plan to achieve the goal "order" for agent Ag
+!order(beer, Qtd)[source(Ag)] <- 
	+orderFrom(Ag, Qtd);
	.println("Pedido de ", Qtd, " cervezas recibido de ", Ag).

// plan para obtener precios
+!pedirPrecio(Producto, Qtd)[source(Ag)] : stockSuper(Producto, CantidadTotal, Precio)<- 
	//+orderFrom(Ag, Qtd);
	.send(Ag, tell, stockSuper(Producto, CantidadTotal, Precio));
	.println("Pedido de ", Qtd, " cervezas recibido de ", Ag);
	.send(Ag, tell, continuar);
	.println("Su pedido es ", Precio, " €.").
	

