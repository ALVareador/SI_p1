/* Initial beliefs and rules */

// initially, I believe that there is some beer in the fridge
available(beer,fridge).

// Inialmente, el robot posee 20 euros
cartera(20).
mejorPrecio(2147483647).
cantidadAOrdenar(3).

// my owner should not consume more than 10 beers a day :-)
limit(beer,5).

too_much(B) :-
   .date(YY,MM,DD) &
   .count(consumed(YY,MM,DD,_,_,_,B),QtdB) &
   limit(B,Limit) &
   QtdB > Limit.

/* Initial goals */

!bringBeer.

/* Plans */

+!bring(myOwner, beer) <-
	+asked(beer).
	
+!bringBeer : healthMsg(_) <- 
	.println("El Robot descansa porque Owner ha bebido mucho hoy.").
+!bringBeer : asked(beer) & not healthMsg(_) <- 
	.println("Owner me ha pedido una cerveza.");
	!go_at(myRobot,fridge);
	!take(fridge,beer);
	!go_at(myRobot,myOwner);
	!hasBeer(myOwner);
	.println("Ya he servido la cerveza y elimino la petición.");
	.abolish(asked(Beer));
	!bringBeer.
+!bringBeer : not asked(beer) & not healthMsg(_) <- 
	.wait(2000);
	.println("Robot esperando la petición de Owner.");
	!bringBeer.

+!take(fridge, beer) : not too_much(beer) <-
	.println("El robot está cogiendo una cerveza.");
	!check(fridge, beer).
+!take(fridge,beer) : too_much(beer) & limit(beer, L) <-
	.concat("The Department of Health does not allow me to give you more than ", L," beers a day! I am very sorry about that!", M);
	-+healthMsg(M).
	
+!check(fridge, beer) : available(beer,fridge) <-
	open(fridge);
	get(beer);
	close(fridge).
+!check(fridge, beer) : not available(beer,fridge) <-
	!pedirCatagolo;
	//!orderBeer(mySupermarket);
	!check(fridge, beer).
+!check(fridge, beer) <-
	!check(fridge, beer).
	
////////////////////////////////////////////////////////////////////////////////
	
+!pedirCatagolo : not ordered(beer) & at(myRobot,fridge)<-
	.println("---------------------------------------------------------------------------------------------------------------------0");
	.send(mySupermarketTwoElectricBoogaloo, achieve, pedirPrecio(beer,3));
	.send(mySupermarket, achieve, pedirPrecio(beer,3));
	!mirarCatalogo.
+!pedirCatagolo.

+!mirarCatalogo : not ordered(beer) <-
	.println("---------------------------------------------------------------------------------------------------------------------1");
	.wait(100);
	!compararPrecios;
	.wait(1000);
	!compararCartera;
	.abolish(mejorPrecio(Ofr));
	+mejorPrecio(2147483647).
+!mirarCatalogo.

+!compararPrecios : stockSuper(beer,CantidadTotal,Precio)[source(Ag)] & cartera(Din) & mejorPrecio(Max) & cantidadAOrdenar(Min) <-
	.println(Ag, " - ", beer, " - ", CantidadTotal, " - ", Precio * 3);
	.println(math.min(Precio,Max));
	+mejorPrecio(math.min(Precio,Max));
	.abolish(mejorPrecio(Max));
	.println(math.min(CantidadTotal,Min));
	+cantidadDisponible(math.min(CantidadTotal,Min));
	//.abolish(cantidadDisponible(Min);
	.println("---------------------------------------------------------------------------------------------------------------------2");
	.abolish(stockSuper(beer,CantidadTotal,Precio)[source(Ag)]);
	.println("---------------------------------------------------------------------------------------------------------------------3");
	!compararStock;
	.println("---------------------------------------------------------------------------------------------------------------------4");
	.abolish(cantidadDisponible(math.min(CantidadTotal,Min))).
	//!mirarCatalogo.
+!compararPrecios.

+!compararCartera : not stockSuper(beer,CantidadTotal,Precio)[source(Ag)] & cartera(Din) & mejorPrecio(Max) <-
	.wait(1000);
	.println("---------------------------------------------------------------------------------------------------------------------5");
	.println(Din, "  ", Max, "  ", math.min(Din, Max));
	+recibo(math.min(Din, Max));
	//comprobarCartera(Max, Din);
	!realizarPedido;
	.abolish(recibo(math.min(Din, Max)));
	.println("---------------------------------------------------------------------------------------------------------------------6").
	
+!compararCartera /*: stockSuper(beer,CantidadTotal,Precio)[source(Ag)] & cartera(Din) & mejorPrecio(Max) */<-
	!mirarCatalogo.
	
+!realizarPedido : recibo(Ofr) & mejorPrecio(Ofr) & cartera(Din)<-
	.println("---------------------------------------------------------------------------------------------------------------------7");
	+cartera(Din - Ofr);
	.abolish(cartera(Din));
	!orderBeer(mySupermarket).
+!realizarPedido.


+!compararStock : not cantidadDisponible(3) & mejorPrecio(Ofr) <-
	.println("---------------------------------------------------------------------------------------------------------------------8");
	.abolish(mejorPrecio(Ofr));
	+mejorPrecio(2147483647).
+!compararStock.

////////////////////////////////////////////////////////////////////////////////
	
+!orderBeer(Supermarket) : not ordered(beer) <-
	.println("El robot realiza un pedido al supermercado.");
	.send(Supermarket, achieve, order(beer,3));
	+ordered(beer).
+!orderBeer(Supermarket).

+!hasBeer(myOwner) : not too_much(beer) <-
	hand_in(beer);
	.println("He preguntado si Owner ha cogido la cerveza.");
	?has(myOwner,beer);
	.println("Se que Owner tiene la cerveza.");
	// remember that another beer has been consumed
	.date(YY,MM,DD); .time(HH,NN,SS);
	+consumed(YY,MM,DD,HH,NN,SS,beer).
+!hasBeer(myOwner) : too_much(beer) & healthMsg(M) <- 
	//.abolish(msg(_));
	.send(myOwner,tell,msg(M)).

+!go_at(myRobot,P) : at(myRobot,P) <- true.
+!go_at(myRobot,P) : not at(myRobot,P)
  <- move_towards(P);
     !go_at(myRobot,P).

// when the supermarket makes a delivery, try the 'has' goal again
+delivered(beer,_Qtd,_OrderId)[source(mySupermarket)] <- 
	+available(beer,fridge);
	-ordered(beer).

// when the fridge is opened, the beer stock is perceived
// and thus the available belief is updated
+stock(beer,0) :  available(beer,fridge) <-
	-available(beer,fridge).
+stock(beer,N) :  N > 0 & not available(beer,fridge) <-
	-+available(beer,fridge).

+?time(T) : true
  <-  time.check(T).

/*
-!bringBeer : true <-
	.current_intention(I);
	.println("Failed to achieve goal '!bring(owner,beer)'.");
	.println("Current intention is: ", I).
*/

