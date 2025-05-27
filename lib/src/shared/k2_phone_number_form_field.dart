import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k2_connect_flutter/src/utils/utils.dart';

class K2PhoneNumberFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const K2PhoneNumberFormField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Column build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 6.0),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: K2Colors.materialDarkBlue.shade100,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Kenya_flag.svg',
                      height: 18,
                      width: 24,
                      package: 'k2_connect_flutter',
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '+254',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: TextFormField(
                  autocorrect: false,
                  autofocus: true,
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  maxLines: 1,
                  maxLength: 11,
                  inputFormatters: [KenyanPhoneNumberFormatter()],
                  style: Theme.of(context).textTheme.displayMedium,
                  decoration: InputDecoration(
                    hintText: '7xx xxx xxx',
                    counterText: '',
                    hintStyle: Theme.of(context).textTheme.displayMedium,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: K2Colors.materialDarkBlue.shade100,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: K2Colors.turquoise,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
