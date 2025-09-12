import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/customers.dart';
import 'package:rebill_flutter/core/providers/customer_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/known_individual_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

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

  // DUMMY SAVE CUSTOMERS
  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final newCustomer = CustomerModel(
        // Get ALL data from controller
        customerName: _nameController.text,
        emailSocial:
            _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        affiliate:
            _affiliateController.text.isNotEmpty
                ? _affiliateController.text
                : null,
        address:
            _addressController.text.isNotEmpty ? _addressController.text : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        postCode:
            _postCodeController.text.isNotEmpty
                ? _postCodeController.text
                : null,
      );

      // Call the action to add the customer AND save the result
      final newCustomerWithId = ref
          .read(customerProvider.notifier)
          .addCustomer(newCustomer);

      // Close the dialog AND send the newly created customer as a result
      Navigator.pop(context, newCustomerWithId);
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
                    SizedBox.shrink(),
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
                              dialogType: DialogType.large,
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
