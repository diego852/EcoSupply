import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showRoleSelectorSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cambiar Perfil y Estado (Demostración)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: EcoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Prueba la experiencia de EcoSupply desde cada rol y estado de acreditación:',
                  style: TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                ),
                const SizedBox(height: 16),

                // Roles
                Column(
                  children: UserRole.values.map((role) {
                    final isSelected = appState.currentRole == role;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? EcoTheme.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? EcoTheme.primary : const Color(0xFFE5E7EB),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          role == UserRole.localUser
                              ? Icons.person_rounded
                              : role == UserRole.business
                                  ? Icons.storefront_rounded
                                  : Icons.volunteer_activism_rounded,
                          color: EcoTheme.primary,
                        ),
                        title: Text(
                          role.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          role.description,
                          style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: EcoTheme.primary)
                            : null,
                        onTap: () {
                          appState.setRole(role);
                          setSheetState(() {});
                        },
                      ),
                    );
                  }).toList(),
                ),

                // Selector de Estado de Acreditación ONG (si rol es ONG)
                if (appState.currentRole == UserRole.socialOrg) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Estado de Acreditación ONG *',
                    style: TextStyle(fontWeight: FontWeight.bold, color: EcoTheme.textDark, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<OngAccreditationStatus>(
                    initialValue: appState.ongStatus,
                    decoration: const InputDecoration(
                      labelText: 'Estado Acreditación',
                      prefixIcon: Icon(Icons.verified_user_rounded, color: EcoTheme.primary),
                    ),
                    items: OngAccreditationStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          status.displayName,
                          style: TextStyle(
                            color: status.canRequestDonations ? EcoTheme.primaryDark : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        appState.setOngStatus(val);
                        setSheetState(() {});
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Guardar Cambios'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, AppState appState) {
    appState.markNotificationsAsRead();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_rounded, color: EcoTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Centro de Notificaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: appState.notifications.isEmpty
                  ? const Center(
                      child: Text('No tienes notificaciones por el momento'),
                    )
                  : ListView.builder(
                      itemCount: appState.notifications.length,
                      itemBuilder: (context, index) {
                        final n = appState.notifications[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(n.body, style: const TextStyle(fontSize: 12)),
                            trailing: Text(
                              '${n.timestamp.hour}:${n.timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 11, color: EcoTheme.textMuted),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isConsumer = appState.currentRole == UserRole.localUser;
    final isOng = appState.currentRole == UserRole.socialOrg;
    final hasUsedQuota = appState.hasUsedMonthlyQuota(appState.userEmail);
    final nextAvailableDate = appState.getNextQuotaAvailableDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => _showNotificationsSheet(context, appState),
              ),
              if (appState.notifications.any((n) => !n.isRead))
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar y Datos del Usuario
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: EcoTheme.primaryLight,
                      child: Icon(
                        appState.currentRole == UserRole.business
                            ? Icons.storefront_rounded
                            : isOng
                                ? Icons.volunteer_activism_rounded
                                : Icons.person_rounded,
                        size: 50,
                        color: EcoTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appState.currentRole == UserRole.business
                          ? appState.businessName
                          : isOng
                              ? appState.orgName
                              : appState.userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: EcoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appState.userEmail,
                      style: const TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                    ),
                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: () => _showRoleSelectorSheet(context, appState),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: EcoTheme.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: EcoTheme.primary),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.swap_horiz_rounded, size: 18, color: EcoTheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Rol: ${appState.currentRole.shortTag}${isOng ? " (${appState.ongStatus.displayName})" : ""}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: EcoTheme.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tarjeta de Restricción / Estado de Cupo Mensual (Consumidor)
              if (isConsumer) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasUsedQuota ? Colors.orange.shade50 : EcoTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasUsedQuota ? Colors.orange.shade400 : EcoTheme.primary,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasUsedQuota ? Icons.calendar_today_rounded : Icons.check_circle_rounded,
                            color: hasUsedQuota ? Colors.orange.shade800 : EcoTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasUsedQuota
                                ? 'Cupo Mensual Utilizado (1/1 Lote)'
                                : 'Cupo Mensual Disponible (0/1 Lote)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: hasUsedQuota ? Colors.orange.shade900 : EcoTheme.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasUsedQuota
                            ? 'Ya tienes una reserva confirmada de 1 Lote Pequeño este mes. Tu próximo cupo estará habilitado el primer día del mes siguiente.'
                            : 'Puedes confirmar 1 Lote Pequeño en Venta Social durante este mes calendario.',
                        style: const TextStyle(fontSize: 13, color: EcoTheme.textDark, height: 1.35),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Próxima reserva disponible:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: EcoTheme.textMuted),
                          ),
                          Text(
                            '1/${nextAvailableDate.month}/${nextAvailableDate.year}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: hasUsedQuota ? Colors.orange.shade900 : EcoTheme.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Estado de Acreditación de la ONG
              if (isOng) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appState.ongStatus.canRequestDonations
                        ? EcoTheme.primaryLight
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: appState.ongStatus.canRequestDonations
                          ? EcoTheme.primary
                          : Colors.red.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            appState.ongStatus.canRequestDonations
                                ? Icons.verified_rounded
                                : Icons.warning_amber_rounded,
                            color: appState.ongStatus.canRequestDonations
                                ? EcoTheme.primary
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Acreditación ONG: ${appState.ongStatus.displayName}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: appState.ongStatus.canRequestDonations
                                  ? EcoTheme.primaryDark
                                  : Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        appState.ongStatus.canRequestDonations
                            ? 'Tu organización está acreditada y habilitada para solicitar donaciones gratuitas y lotes medianos/grandes.'
                            : 'Las donaciones y lotes grandes requieren estado "Acreditada". Contacta con el equipo de EcoSupply para regularizar tu acreditación.',
                        style: const TextStyle(fontSize: 13, color: EcoTheme.textDark, height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Card(
                child: ListTile(
                  leading: const Icon(Icons.published_with_changes_rounded, color: EcoTheme.primary),
                  title: const Text('Cambiar rol o estado de acreditación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Simular experiencia como Consumidor, Comercio u ONG', style: TextStyle(fontSize: 12, color: EcoTheme.textMuted)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _showRoleSelectorSheet(context, appState),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined, color: EcoTheme.primary),
                      title: const Text('Centro de Notificaciones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: Text('${appState.notifications.length}', style: const TextStyle(color: EcoTheme.primary, fontWeight: FontWeight.bold)),
                      onTap: () => _showNotificationsSheet(context, appState),
                    ),
                    const Divider(height: 1, indent: 50),
                    const ListTile(
                      leading: Icon(Icons.all_inbox_rounded, color: EcoTheme.primary),
                      title: Text('Regla de Lotes Completos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('Ventas y donaciones por lote cerrado', style: TextStyle(fontSize: 12, color: EcoTheme.textMuted)),
                    ),
                    const Divider(height: 1, indent: 50),
                    const ListTile(
                      leading: Icon(Icons.language_rounded, color: EcoTheme.primary),
                      title: Text('Idioma', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: Text('Español (Perú)', style: TextStyle(color: EcoTheme.textMuted, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'EcoSupply v1.0.0 • Sistema de Lotes & Acreditación de ONGs',
                style: TextStyle(fontSize: 11, color: EcoTheme.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
