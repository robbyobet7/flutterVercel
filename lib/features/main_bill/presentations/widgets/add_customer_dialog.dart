import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/features/main_bill/models/customer.dart';
import 'package:rebill_flutter/features/main_bill/presentations/pages/known_individual_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_bill_provider.dart';

class AddCustomerDialog extends ConsumerStatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  ConsumerState<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _affiliateController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postCodeController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _affiliateController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postCodeController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      // Create a new customer object
      // Note: address, city, and postCode aren't in the Customer model
      // We're storing address in email field temporarily for demonstration
      final customer = Customer(
        id:
            _idController.text.isEmpty
                ? 'CUS${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
                : _idController.text,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        affiliate: _affiliateController.text,
        joinDate: DateTime.now().toString().split(' ')[0], // Current date
        balance: '0.00', // Default balance
      );

      // Store additional fields in user metadata or extended profile
      // (This would be implemented in a real application)

      // For now, we'll just close the dialog and pass back the customer
      Navigator.pop(context, customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDivider(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  spacing: 16,
                  children: [
                    SizedBox.shrink(), //spacer only
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _idController,
                            labelText: 'Customer ID',
                            hintText: 'Auto-generated if empty',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            controller: _nameController,
                            labelText: 'Name',
                            hintText: 'Enter customer name',
                            required: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    AppTextField(
                      controller: _addressController,
                      labelText: 'Address',
                      hintText: 'Enter customer address',
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _cityController,
                            labelText: 'City',
                            hintText: 'Enter city',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            controller: _postCodeController,
                            labelText: 'Post Code',
                            hintText: 'Enter post code',
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _emailController,
                            labelText: 'Email/Social',
                            hintText: 'Enter email or social',
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            controller: _phoneController,
                            labelText: 'Phone',
                            hintText: 'Enter phone number',
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),

                    AppTextField(
                      controller: _affiliateController,
                      labelText: 'Affiliate',
                      hintText: 'Enter affiliate',
                    ),
                  ],
                ),
              ),
            ),
            Column(
              spacing: 16,
              children: [
                AppDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      onPressed:
                          () => {
                            Navigator.pop(context),
                            AppDialog.showCustom(
                              context,
                              content: KnownIndividualDialog(),
                              title: 'Known Individual',
                              onClose: () {
                                ref
                                    .read(knownIndividualProvider.notifier)
                                    .setKnownIndividual(null);
                              },
                            ),
                          },
                      text: 'Back to Individual',
                      backgroundColor: theme.colorScheme.errorContainer,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    AppButton(
                      onPressed: _saveCustomer,
                      text: 'Save Customer',
                      backgroundColor: theme.colorScheme.primary,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
