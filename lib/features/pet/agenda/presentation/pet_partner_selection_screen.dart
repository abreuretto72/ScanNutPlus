import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/agenda/data/models/partner_model.dart';
import 'package:scannutplus/features/pet/agenda/logic/pet_partner_service.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class PetPartnerSelectionScreen extends StatefulWidget {
  const PetPartnerSelectionScreen({super.key});

  @override
  State<PetPartnerSelectionScreen> createState() => _PetPartnerSelectionScreenState();
}

class _PetPartnerSelectionScreenState extends State<PetPartnerSelectionScreen> {
  bool _isSearchingPartners = false;
  List<Partner> _allPartners = [];
  List<Partner> _filteredPartners = [];
  
  Partner? _selectedPartner;
  String _selectedCategoryFilter = 'Todos'; // Default filter

  final List<String> _filterCategories = [
    'Todos', 'Saúde', 'Hospitalidade', 'Estética', 'Educação', 'Serviços'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchPartners(forceRefresh: false, l10n: AppLocalizations.of(context)!);
      }
    });
  }

  Future<void> _fetchPartners({bool forceRefresh = false, required AppLocalizations l10n}) async {
    setState(() {
      _isSearchingPartners = true;
      _selectedPartner = null;
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
          throw Exception(l10n.error_location_disabled);
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(l10n.error_location_denied);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(l10n.error_location_permanently_denied);
      }

      Position position = await Geolocator.getCurrentPosition();
      
      final places = await PetPartnerService.fetchNearbyPartners(
        position.latitude, 
        position.longitude, 
        forceRefresh: forceRefresh
      );

      if (mounted) {
        setState(() {
          _allPartners = places;
          _applyFilter();
        });
      }
    } catch (e) {
      debugPrint('[PetPartnerSelectionScreen] Erro: $e');
      if (mounted) {
         final errorL10n = AppLocalizations.of(context)!;
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(errorL10n.error_fetching_places(e.toString())), backgroundColor: Colors.red),
         );
      }
    } finally {
      if (mounted) setState(() => _isSearchingPartners = false);
    }
  }

  void _applyFilter() {
    if (_selectedCategoryFilter == 'Todos') {
      _filteredPartners = List.from(_allPartners);
    } else {
      _filteredPartners = _allPartners.where((p) => p.category == _selectedCategoryFilter).toList();
    }
    // Force Dropdown to reset if the selected partner is filtered out
    if (_selectedPartner != null && !_filteredPartners.contains(_selectedPartner)) {
      _selectedPartner = null;
    }
  }

  Future<void> _onPartnerSelected(Partner partner) async {
    setState(() {
       _selectedPartner = partner;
       _isSearchingPartners = true; // Temporary loading layer for details
    });

    // Bring contact details (phone, exact address)
    final details = await PetPartnerService.fetchPlaceDetails(partner.id);
    
    if (mounted) {
      setState(() {
         // Create a new Partner instance or modify the existing one to append the exact details
         // Since modifying the object might affect the cached list reference, it's safe to just
         // assign phone and address.
         
         // In Dart, assigning to final fields requires creating a new object or having them non-final.
         // Let's just create a new enriched Partner to return.
         _selectedPartner = Partner(
            id: partner.id,
            name: partner.name,
            address: details['address'] ?? partner.address,
            rating: partner.rating,
            totalRatings: partner.totalRatings,
            isOpenNow: partner.isOpenNow,
            phoneNumber: details['phone'] ?? partner.phoneNumber,
            website: partner.website,
            location: partner.location,
            types: partner.types,
            distanceRaw: partner.distanceRaw,
            category: partner.category,
         );
         _isSearchingPartners = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(_selectedPartner != null ? appL10n.partner_about : appL10n.partner_network_search, 
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: _selectedPartner != null 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.petPrimary), 
                onPressed: () => setState(() => _selectedPartner = null)
              )
            : const BackButton(),
        actions: _selectedPartner == null ? [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.petPrimary, size: 28),
            tooltip: appL10n.partner_force_search_restart,
            onPressed: () => _fetchPartners(forceRefresh: true, l10n: appL10n),
          ),
          const SizedBox(width: 8),
        ] : null,
      ),
      body: _isSearchingPartners && _allPartners.isEmpty 
          ? const Center(child: CircularProgressIndicator(color: AppColors.petPrimary, strokeWidth: 4))
          : (_selectedPartner != null)
              ? _buildPartnerDetails()
              : _buildSearchList(appL10n),
    );
  }

  String _translateCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Todos': return l10n.partner_filter_all;
      case 'Saúde': return l10n.partner_filter_health;
      case 'Hospitalidade': return l10n.partner_filter_hospitality;
      case 'Estética': return l10n.partner_filter_aesthetics;
      case 'Educação': return l10n.partner_filter_education;
      case 'Serviços': return l10n.partner_filter_services;
      default: return category;
    }
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.storefront_rounded;
    switch (category) {
      case 'Saúde':
        return Icons.medical_services_rounded;
      case 'Hospitalidade':
        return Icons.hotel_rounded;
      case 'Estética':
        return Icons.content_cut_rounded;
      case 'Educação':
        return Icons.school_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  Widget _buildSearchList(AppLocalizations appL10n) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pro-Max Category Filter Chips (Playful/Chunky)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _filterCategories.map((cat) {
                final isSelected = _selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.petPrimary : Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.black : Colors.white24, width: 2),
                      boxShadow: isSelected ? [
                        const BoxShadow(color: Colors.black, offset: Offset(4, 4))
                      ] : [],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            _selectedCategoryFilter = cat;
                            _applyFilter();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Text(
                            _translateCategory(cat, appL10n), 
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70, 
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              letterSpacing: 0.5,
                            )
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          if (_isSearchingPartners && _allPartners.isNotEmpty) 
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 0.0),
                child: LinearProgressIndicator(color: AppColors.petPrimary, backgroundColor: Colors.transparent, minHeight: 4),
              ),
              
          Expanded(
            child: _filteredPartners.isEmpty && !_isSearchingPartners
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('🐾 Nenhum local encontrado para esta categoria perto daqui.', 
                      style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w600, height: 1.5), 
                      textAlign: TextAlign.center),
                  )
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredPartners.length,
                  itemBuilder: (context, index) {
                     final partner = _filteredPartners[index];
                     // Playful Card Style
                     return Container(
                       margin: const EdgeInsets.only(bottom: 16),
                       decoration: BoxDecoration(
                         color: Colors.grey[900], // Dark grey for contrast against black background
                         borderRadius: BorderRadius.circular(24),
                         border: Border.all(color: Colors.black, width: 3),
                         boxShadow: const [
                            BoxShadow(color: Colors.black, offset: Offset(4, 4))
                         ],
                       ),
                       child: Material(
                         color: Colors.transparent,
                         child: InkWell(
                           borderRadius: BorderRadius.circular(24),
                           onTap: () => _onPartnerSelected(partner),
                           child: Padding(
                             padding: const EdgeInsets.all(20),
                             child: Row(
                               children: [
                                  // Icon Bubble
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.petPrimary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black, width: 2),
                                    ),
                                    child: Icon(_getCategoryIcon(partner.category), color: Colors.black, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  // Data
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(partner.name, 
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.3), 
                                          maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                             Container(
                                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                               decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                                               child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.star_rounded, color: AppColors.petPrimary, size: 14),
                                                    const SizedBox(width: 4),
                                                    Text('', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                                                  ],
                                               ),
                                             ),
                                             const SizedBox(width: 12),
                                             const Icon(Icons.location_on_rounded, color: Colors.white54, size: 14),
                                             const SizedBox(width: 4),
                                             Text(partner.formattedDistance, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                                    child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                                  ),
                               ],
                             ),
                           ),
                         ),
                       ),
                     );
                  },
              )
          ),
        ],
     );
  }

  Widget _buildPartnerDetails() {
     final appL10n = AppLocalizations.of(context)!;
     if (_isSearchingPartners) {
        return Center(
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                const CircularProgressIndicator(color: AppColors.petPrimary, strokeWidth: 4),
                const SizedBox(height: 24),
                Text(appL10n.partner_syncing_contacts, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 16)),
             ],
           ),
        );
     }
  
     return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.petPrimary, // Rosa Pastel Master
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: const [
               BoxShadow(color: Colors.black, offset: Offset(8, 8)) // Chunky brutalist shadow
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Expanded(
                      child: Text(
                        _selectedPartner!.name, 
                        style: const TextStyle(color: Colors.black, fontSize: 28, height: 1.1, fontWeight: FontWeight.w900, letterSpacing: -0.5)
                      ),
                    ),
                    if (_selectedPartner!.isOpenNow)
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                         decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white, width: 2)),
                         child: Text(appL10n.partner_open_now, style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                       ),
                 ],
               ),
               const SizedBox(height: 20),
               
               Wrap(
                 spacing: 8,
                 runSpacing: 8,
                 children: [
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width: 2)),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                          const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
                          const SizedBox(width: 6),
                          Text(' ( reviews)', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                       ],
                     ),
                   ),
                   if (_selectedPartner!.category != null)
                     Container(
                       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                       decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
                       child: Text(_translateCategory(_selectedPartner!.category!, appL10n).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0)),
                     ),
                 ]
               ),
               
               const Padding(
                 padding: EdgeInsets.symmetric(vertical: 28),
                 child: Divider(color: Colors.black, height: 1, thickness: 3),
               ),
               
               _buildInfoRow(Icons.location_on_rounded, _selectedPartner!.address),
               if (_selectedPartner!.phoneNumber != null) ...[
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.phone_rounded, _selectedPartner!.phoneNumber!),
               ],
               
               const SizedBox(height: 48),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                     // Return the selected partner back to the previous screen
                     Navigator.pop(context, _selectedPartner);
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.black,
                     foregroundColor: Colors.white,
                     elevation: 0,
                     padding: const EdgeInsets.symmetric(vertical: 22),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                     side: const BorderSide(color: Colors.white, width: 2),
                   ),
                   child: Text(appL10n.partner_select_this, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                 ),
               )
            ],
          ),
        ),
     );
  }

  Widget _buildInfoRow(IconData icon, String text) {
     return Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Container(
           padding: const EdgeInsets.all(12),
           decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
           child: Icon(icon, color: Colors.black, size: 24)
         ),
         const SizedBox(width: 20),
         Expanded(
           child: Padding(
             padding: const EdgeInsets.only(top: 8.0),
             child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w800, height: 1.4)),
           ),
         )
       ],
     );
  }
}
