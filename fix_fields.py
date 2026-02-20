import re

file_path = "lib/features/pet/agenda/presentation/pet_appointment_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    text = f.read()

# 1. Inject the Wrapper Method
wrapper_method = """  Widget _buildLabeledField(String labelText, Widget child) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: child,
        ),
        Positioned(
          left: 16,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black, width: 0),
            ),
            child: Text(
              labelText.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String labelText, IconData icon) {"""
old_dec = "  InputDecoration _inputDecoration(String label, IconData icon) {"
text = text.replace(old_dec, wrapper_method)

# 2. Extract out the container label from _inputDecoration
old_label_container = """      label: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label.toUpperCase(), 
          style: const TextStyle(
             color: Colors.white, 
             fontWeight: FontWeight.w900, 
             fontSize: 11, 
             letterSpacing: 1.0
          )
        ),
      ),
      hintText: label,"""
text = text.replace(old_label_container, "      hintText: labelText,")


# 3. Replace the fields manually
cat_old = """                          DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedCategory,"""
cat_new = """                          _buildLabeledField(l10n.pet_apt_select_category, DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedCategory,"""
text = text.replace(cat_old, cat_new).replace("                            },", "                            },").replace("                          ),\n                          const SizedBox(height: 16),", "                          )),\n                          const SizedBox(height: 16),", 1)


type_old = """                          DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedType,"""
type_new = """                          _buildLabeledField(l10n.pet_apt_select_type, DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedType,"""
text = text.replace(type_old, type_new).replace("                            onChanged: (val) => setState(() => _selectedType = val!),\n                          ),\n                          const SizedBox(height: 16),", "                            onChanged: (val) => setState(() => _selectedType = val!),\n                          )),\n                          const SizedBox(height: 16),", 1)


title_old = """                          TextFormField(
                            controller: _titleController,"""
title_new = """                          _buildLabeledField(l10n.pet_field_what_to_do, TextFormField(
                            controller: _titleController,"""
text = text.replace(title_old, title_new).replace("                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                          ),\n                          const SizedBox(height: 16),", "                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                          )),\n                          const SizedBox(height: 16),", 1)


dt_old = """                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: _inputDecoration(l10n.pet_agenda_event_date, Icons.calendar_today),
                                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context),
                                  child: InputDecorator(
                                    decoration: _inputDecoration(l10n.pet_field_time, Icons.access_time),
                                    child: Text(_selectedTime.format(context), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                ),
                              ),"""
dt_new = """                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context),
                                  child: _buildLabeledField(l10n.pet_agenda_event_date, InputDecorator(
                                    decoration: _inputDecoration(l10n.pet_agenda_event_date, Icons.calendar_today),
                                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                  )),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context),
                                  child: _buildLabeledField(l10n.pet_field_time, InputDecorator(
                                    decoration: _inputDecoration(l10n.pet_field_time, Icons.access_time),
                                    child: Text(_selectedTime.format(context), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                  )),
                                ),
                              ),"""
text = text.replace(dt_old, dt_new)


notif_old = """                          DropdownButtonFormField<String>(
                            value: _selectedLeadTime,"""
notif_new = """                          _buildLabeledField(l10n.pet_notification_label, DropdownButtonFormField<String>(
                            value: _selectedLeadTime,"""
text = text.replace(notif_old, notif_new).replace("                            onChanged: (val) => setState(() => _selectedLeadTime = val!),\n                          ),\n                          const SizedBox(height: 16),", "                            onChanged: (val) => setState(() => _selectedLeadTime = val!),\n                          )),\n                          const SizedBox(height: 16),", 1)

partner_old = """                            DropdownButtonFormField<String>(
                              value: _selectedPartner,"""
partner_new = """                            _buildLabeledField(l10n.pet_field_partner_name, DropdownButtonFormField<String>(
                              value: _selectedPartner,"""
text = text.replace(partner_old, partner_new).replace("                              },\n                            ),\n                            \n                            // CONDITIONAL NEW PARTNER LOGIC", "                              },\n                            )),\n                            \n                            // CONDITIONAL NEW PARTNER LOGIC", 1)


newname_old = """                               TextFormField(
                                  controller: _professionalController,"""
newname_new = """                               _buildLabeledField("${l10n.pet_appointment_new_partner} *", TextFormField(
                                  controller: _professionalController,"""
text = text.replace(newname_old, newname_new).replace("                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                               ),\n                            ],", "                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                               )),\n                            ],", 1)


contact_old = """                            TextFormField(
                              controller: _partnerContactController,"""
contact_new = """                            _buildLabeledField(l10n.pet_field_contact_person, TextFormField(
                              controller: _partnerContactController,"""
text = text.replace(contact_old, contact_new).replace("                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                            ),\n                            const SizedBox(height: 16),", "                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                            )),\n                            const SizedBox(height: 16),", 1)


tel_old = """                            TextFormField(
                              controller: _partnerPhoneController,"""
tel_new = """                            _buildLabeledField(l10n.pet_field_phone, TextFormField(
                              controller: _partnerPhoneController,"""
text = text.replace(tel_old, tel_new).replace("                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                            ),\n                            const SizedBox(height: 16),", "                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                            )),\n                            const SizedBox(height: 16),", 2) # There are two of these pattern matches now, let's trace carefully

wpp_old = """                            TextFormField(
                              controller: _partnerWhatsappController,"""
wpp_new = """                            _buildLabeledField(l10n.pet_field_whatsapp, TextFormField(
                              controller: _partnerWhatsappController,"""
text = text.replace(wpp_old, wpp_new).replace("                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                            ),\n                            const SizedBox(height: 16),", "                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                            )),\n                            const SizedBox(height: 16),", 3)

mail_old = """                            TextFormField(
                              controller: _partnerEmailController,"""
mail_new = """                            _buildLabeledField(l10n.pet_field_email, TextFormField(
                              controller: _partnerEmailController,"""
text = text.replace(mail_old, mail_new).replace("                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                            ),\n\n                         ],", "                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),\n                            )),\n\n                         ],", 1)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(text)

print("Replacement complete for pet_appointment_screen.dart.")
