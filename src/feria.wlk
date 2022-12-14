class Feria {

	const property puestos = []

	method agregarPuesto(puesto) {
		puestos.add(puesto)
	}

	method cualesPuedeVisitar(persona) {
		return puestos.filter({ puesto => puesto.puedeSerUsado(persona) })
	}

	method visitoAlmenosUnPuesto(persona) {
		return puestos.any({ puesto => puesto.fueVisitadoPor(persona) })
	}

	method cuantosApadrina(municipio) {
		return puestos.count({ puesto => puesto.municipio().equals(municipio) })
	}

	method municipiosApadrinantes() {
		return puestos.map({ puesto => puesto.municipio() }).asSet().asList()
	}

	method promedioRecaudacioinMunicipios() {
		const cantidadDeMunicipios = self.municipiosApadrinantes().size()
		return self.municipiosApadrinantes().sum({ municipio => municipio.recaudado() }) / cantidadDeMunicipios
	}

	method municipioMenosRecaudo() {
		return self.municipiosApadrinantes().min({ municipio => municipio.recaudado() })
	}

}

class Puesto {

	var property municipio
	var property visitantes = []

	method puedeSerUsado(persona)

	method usar(persona) {
		self.validaPuedeSerUsado(persona)
		visitantes.add(persona)
	}

	method validaPuedeSerUsado(persona) {
		if (not self.puedeSerUsado(persona)) {
			self.error("no puede ser usado por esta persona")
		}
	}

	method fueVisitadoPor(persona) {
		return visitantes.contains(persona)
	}

}

class Infantil inherits Puesto {

	var property premio = 10

	override method puedeSerUsado(persona) {
		return persona.edad() < 18
	}

	override method usar(persona) {
		super(persona)
		persona.ganar(premio)
	}

}

class Comercial inherits Puesto {

	var property costo = 10

	override method puedeSerUsado(persona) {
		return persona.dinero() >= costo
	}

	override method usar(persona) {
		super(persona)
		persona.pagar(costo)
	}

}

class Impositivo inherits Puesto {

	override method puedeSerUsado(persona) {
		return self.esResidente(persona) and persona.tieneDeuda() and persona.puedePagar(municipio.montoExigible(persona))
	}

	override method usar(persona) {
		super(persona)
		municipio.recibirPago(persona)
			// el órden de recibir pago y pagar deuda importa, porque si primero paga la deuda
			// luego municipio.recibirPago() ya no encontraría deuda
		persona.pagarDeuda()
	}

	method esResidente(persona) {
		return persona.municipio().equals(municipio)
	}

}

class Municipio {

	var property recaudado = 0

	method montoExigible(persona) {
		return self.montoBruto(persona) - self.montoProrrogable(persona)
	}

	method montoBruto(persona) {
		return persona.deudaMunicipal()
	}

	method montoProrrogable(persona) {
		return if (self.condicionEdad(persona)) self.montoBruto(persona) * 0.1 else 0
	}

	method condicionEdad(persona) {
		return persona.esMayorQue(75)
	}

	method recibirPago(persona) {
		recaudado += self.montoExigible(persona)
	}

}

class MunicipioRelajado inherits Municipio {

	override method montoBruto(persona) {
		return persona.deudaMunicipal().min(persona.dinero())
	}

}

class MunicipioHiperRelajado inherits MunicipioRelajado {

	override method montoBruto(persona) {
		return super(persona) * 0.8
	}

	override method montoProrrogable(persona) {
		return super(persona) * 2
	}

	override method condicionEdad(persona) {
		return persona.esMayorQue(60)
	}

}

class Visitante {

	var property dinero
	var property edad
	var property municipio
	var property deudaMunicipal

	method pagar(costo) {
		dinero -= costo
	}

	method ganar(premio) {
		dinero += premio
	}

	method tieneDeuda() {
		return deudaMunicipal > 0
	}

	method esMayorQue(numero) {
		return edad > numero
	}

	method puedePagar(monto) {
		return dinero >= monto
	}

	method pagarDeuda() {
		const monto = municipio.montoExigible(self)
		self.pagar(monto)
		deudaMunicipal -= monto
	}

}

