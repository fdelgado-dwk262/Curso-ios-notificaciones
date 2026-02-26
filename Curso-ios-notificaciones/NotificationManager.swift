//
//  NotificacionManager.swift
//  Curso-ios-notificaciones
//
//  Created by Equipo 9 on 25/2/26.
//

import SwiftUI
import UserNotifications

@Observable
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    var estadoDeLaAutorizacion: UNAuthorizationStatus = .notDetermined

    var idRecordatorio: String?

    override init() {
        super.init()
        // un singelton .-
        UNUserNotificationCenter.current().delegate = self

        Task {
            await comprobarEstadoDePermisos()
        }
    }

    @MainActor
    func comprobarEstadoDePermisos() async {
        let settings = await UNUserNotificationCenter.current()
            .notificationSettings()
        self.estadoDeLaAutorizacion = settings.authorizationStatus
    }

    func solicitarPermiso() async {
        do {
            // lanza la modal el aviso de sistema una sola vez para que el usuario acepte o deniegue
            // si la rechazamos nos llevara a los ajustes y el usuario lo tiene que hacer de froma manual
            try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound])
            await comprobarEstadoDePermisos()
        } catch {
            print(
                "Error al solicitar los permisos: \(error.localizedDescription)"
            )
        }
    }

    // la funcion poara aplicar la notificación y programarla en el teléfono
    func programaNotificacion(titulo: String, date: Date) {
        // comprobamos que esta con permisos
        guard estadoDeLaAutorizacion == .authorized else {
            return
        }
        
        //
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio 📅"
        content.body = titulo
        content.sound = .defaultCritical
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        // el lanzador de la alerta . Si ponemos repeat a true se repetira cada día
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let notificacion = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notificacion) { error in
            if let error = error {
                print("Error al programar la notificación: \(error.localizedDescription)")
            } else {
                print("Notificación programada correctamente")
            }
        }
    }
    
    // TODO: funcion que puede sar llamada para eliminar la notificación programada
    func cancelarNotificaciones() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // TODO: Consultar las notificaciones pendientes
    func notificacionesPendientes() async {
        let notificacionesPendientes = await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    // MARK: Métodos delegados ⤵️.- implementamos
    // Caso de notificación .- cuando la app esta abierta
    // se ejecuta en el hilo principal
    @MainActor
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notication: UNNotification
    ) async -> UNNotificationPresentationOptions {
        print("Notificación recibida en primer plano")
        return [.banner, .sound]
    }

    // Caso de notificación .- cuando esta cerrada o en background
    @MainActor
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // El titulo del recordatorio lo hemos puesto en el body
        // en la funcion programarNotificacion() y el usuario clica en la notificación nativa
        let titulo = response.notification.request.content.body
        
        // para debug .-
        print(
            "El usuario ha pulsado la Notificación: \(titulo)"
        )
        
        // cambiamos el ID del recordatorio .-
        self.idRecordatorio = titulo
    }

}
