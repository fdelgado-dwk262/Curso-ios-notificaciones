//
//  ContentView.swift
//  Curso-ios-notificaciones
//
//  Created by Equipo 9 on 25/2/26.
//

import SwiftUI

struct VistaPrincipal: View {
    
    @Environment(NotificationManager.self) var manager
    
    @State private var horaProgramada = Date()
    @State private var recodatorio = "Commiteaaaa ar-🐐-vos"
    
    // el usuario puede rechazar los permisos
    // y se pide al usuario que los active
    // control
    @State private var mostrarAlertaAjustes = false
    @State private var mostrarMensajeExito: Bool = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Datos") {
                    TextField("Recordatorio", text: $recodatorio)
                    DatePicker("Hora", selection: $horaProgramada, displayedComponents: .hourAndMinute)
                }
                Section("Permisos") {
                    HStack {
                        Text("Estado de permisos:")
                        Spacer()
                        // TODO: mini vista para los permismos
                        VistaEstadoPermisos(status: manager.estadoDeLaAutorizacion)
                    }
                }
                
                //
                Section("En función del estado haremos varias cosas") {
                    Button("Programar aviso") {
                        // Hará varias cosas en función si estan o no las notificaciones habilitadas
                        programarAccionDeAviso()
                    }
                }
            }
            
            
            .navigationTitle(Text("Notificaciones"))
            
            // Cuando el usuario clica en la notificacion, se actualiza idRecordatorio y navega a VistaDetalle
            .navigationDestination(item: Bindable(manager).idRecordatorio) { tituloRecordatorio in
                VistaDetalle(texto: tituloRecordatorio)
            }
            
            // ios tioene una comunicación interna NotificacionCenter entre la app y el sistema
            // en el caso que el usuario viene de los ajustes al conceder o no los permisos
            
            // unidireccional .- sistema IOS a la app
            // envio brodcats, y la app se registra para observar cambios en el sistema
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await manager.comprobarEstadoDePermisos()
                }
            }
            
            
            // closure de funciones
            .alert("Permisos necesarios", isPresented: $mostrarAlertaAjustes) {
                Button("Cancelar", role: .cancel) {}
                Button("Ir a Ajustes") {
                    // Este código nos abre la ventana de ajustes
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Haz desactivado las notificaciones, por favor activalas para poder usarla")
            }
            
            // Popup .- Temporal de que la notificación se ha programado
            .overlay(alignment: .bottom) {
                if mostrarMensajeExito {
                    Text("✅ Notificación programada")
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .transition(.move(edge: .bottom))
                        .padding(.bottom, 50)
                    
                }
                
            }
        }
        
    }
    
    // Según el estado hacemos una u otra cosa
    func programarAccionDeAviso() {
        switch manager.estadoDeLaAutorizacion {
        case .authorized:
            
            // TODO: pendiente
            manager.programaNotificacion(titulo: recodatorio, date: horaProgramada)
            
            withAnimation{
                mostrarMensajeExito = true
            }
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                await MainActor.run {
                    withAnimation {
                        mostrarMensajeExito = false
                    }
                }
            }
            
        case .notDetermined:
            // al ser la primera vez, pedimos los permisos
            Task {
                await manager.solicitarPermiso()
                if manager.estadoDeLaAutorizacion == .authorized {
                    manager.programaNotificacion(titulo: recodatorio, date: horaProgramada)
                }
            }
        case .denied:
            // El usuario ha bloquedao los permisos y necesitamos una alerta para que el usuario desbloquee los permisos
            mostrarAlertaAjustes = true
            
        default:
            break
            
        }
        
    }
}

struct VistaDetalle: View {
    
    let texto: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)
                .symbolEffect(.bounce)
            
            Text("¡Recortadotrio recibido!")
                .font(.title2)
                .bold()
            
            Text(texto)
                .font(.body)
                .padding()
                .background(Color.orange.opacity(0.2))
                .cornerRadius(10)
            
            // TODO: Necesitamos Programática para volver a la pantalla principal
//            Button("Aceptar") {
//                
//            }
            
        }
        .navigationTitle("Recordatorio")
    }
}

struct VistaEstadoPermisos: View {
    let status : UNAuthorizationStatus
    
    var body: some View {
        switch status {
        case .authorized:
            Text("Autorizado").foregroundStyle(Color.green)
        case .denied:
            Text("Denegado").foregroundStyle(Color.red)
        case .notDetermined:
            Text("Pendiente").foregroundStyle(Color.orange)
        default:
            Text("Otros ...").foregroundStyle(Color.gray)
        }
    }
}


#Preview("vista rpincipal") {
    VistaPrincipal()
        .environment(NotificationManager())
}

#Preview("vista detalle") {
    return NavigationStack {
        VistaDetalle(texto: "Comitea ar-🐐-vos")
    }
    
}

#Preview("vista Estao Permisos") {
    VistaEstadoPermisos(status: .authorized)
}
