import re

file_path = r'e:\antigravity_projetos\ScanNutPlus\lib\features\pet\agenda\presentation\pet_scheduled_events_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    orig_content = f.read()

# Let's cleanly replace the entire itemBuilder block to ensure brackets are perfect.
pattern = r'itemBuilder: \((context, index)\) \{(.*?)\s+const SizedBox\(height: 80\),\s*\],\s*\),\s*\),\s*\),\s*\);\s*}\s*void _confirmDelete'
replacement = r'''itemBuilder: (context, index) {
                    final event = _appointments[index];
                    final rawTitle = event.metrics?.get('custom_title')?.toString();
                    final title = rawTitle != null ? rawTitle : l10n.pet_appointment_tab_data;
                    final professional = event.metrics?.get('professional')?.toString() ?? '';
                    final leadTime = event.metrics?.get('notification_lead_time')?.toString();
                    
                    final appointmentType = event.metrics?.get('appointment_type')?.toString();
                    final typeDisplay = appointmentType != null ? appointmentType : null;

                    final whatToDo = event.notes ?? '';
                    
                    final rawCategory = event.eventTypeIndex == PetEventType.health.index ? l10n.pet_appointment_cat_health 
                        : event.eventTypeIndex == PetEventType.food.index ? l10n.pet_appointment_cat_nutrition 
                        : l10n.pet_appointment_tab_data;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showEventActionsModal(context, event),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.petPrimary,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.black, width: 3),
                              boxShadow: const [
                                 BoxShadow(color: Colors.black, offset: Offset(6, 6))
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.black, width: 2),
                                            ),
                                            child: const Icon(Icons.calendar_month_rounded, color: Colors.black, size: 24),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              rawCategory.toUpperCase(), 
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2),
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.black54),
                                        onPressed: () => _confirmDelete(context, event.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    title,
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20),
                                  ),
                                  if (typeDisplay != null) ...[
                                     const SizedBox(height: 4),
                                     Text(
                                       typeDisplay.toUpperCase(),
                                       style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 14),
                                     ),
                                  ],
                                  if (whatToDo.isNotEmpty) ...[
                                     const SizedBox(height: 8),
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                       decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.black, width: 1.5),
                                       ),
                                       child: Text(
                                         "\: \",
                                         style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, fontSize: 13),
                                       ),
                                     ),
                                  ],
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Divider(color: Colors.black, height: 1, thickness: 3),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, color: Colors.black, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          DateFormat('dd/MM/yyyy • HH:mm').format(event.startDateTime),
                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (leadTime != null && leadTime != 'none')
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 1.5)),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.notifications_active_rounded, size: 14, color: Colors.black),
                                              const SizedBox(width: 4),
                                              Text(leadTime, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (professional.isNotEmpty) ...[
                                     const SizedBox(height: 12),
                                     Row(
                                       children: [
                                         const Icon(Icons.storefront_rounded, color: Colors.black, size: 20),
                                         const SizedBox(width: 8),
                                         Expanded(
                                           child: Text(
                                             "\: \", 
                                             style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14),
                                             overflow: TextOverflow.ellipsis,
                                           ),
                                         ),
                                       ],
                                     ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete'''

new_content = re.sub(pattern, replacement, orig_content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Block replaced!")
