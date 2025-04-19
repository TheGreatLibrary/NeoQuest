import 'package:flutter/material.dart';

/// текстовое поле с контроллером, фокусом и сообщением об ошибке
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String errorLabel;
  final String placeholder;
  final bool isError;
  final FocusNode currentFocus;
  final FocusNode? nextFocus;
  final bool necessarily;

  const CustomTextField(
      {super.key,
        required this.controller,
        required this.label,
        required this.errorLabel,
        required this.placeholder,
        required this.isError,
        required this.currentFocus,
        required this.nextFocus,
        this.necessarily = true
      });

  @override
  _CustomTextFieldState createState() {
    return _CustomTextFieldState();
  }
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _hasFocus;

  @override
  void initState() {
    super.initState();
    _hasFocus = widget.currentFocus.hasFocus;
    widget.currentFocus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.currentFocus.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = widget.currentFocus.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith( fontWeight: FontWeight.w900)
              ),
              if (widget.necessarily)
                TextSpan(
                text: '*',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Color(0xFFD1005B))
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(
              begin: const Alignment(-1, 0.00),
              end: const Alignment(1, 0),
              colors: widget.isError
                  ? const [Color(0xFFD1005B), Color(0xFFD1005B)]
                  : _hasFocus
                  ? const [Color(0xFFD1005B), Color(0xFFE8772F)]
                  : const [Color(0xFF595959), Color(0xFF595959)],
            ),
          ),
          padding: const EdgeInsets.all(1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white,
            ),
            child: TextSelectionTheme(
              data: const TextSelectionThemeData(
                selectionColor: Color(0x7EE8772F),
                cursorColor: Color(0xFFE8772F),
                selectionHandleColor: Color(0x7EE8772F),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.currentFocus,
                textInputAction: widget.nextFocus != null
                    ? TextInputAction.next
                    : TextInputAction.done,
                onSubmitted: (_) {
                  if (widget.nextFocus != null) {
                    FocusScope.of(context).requestFocus(widget.nextFocus);
                  } else {
                    widget.currentFocus.unfocus();
                  }
                },
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Color(0xFF585858)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
            height: 30,
            child: widget.isError
                ? Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Text(
                widget.errorLabel,
                style: const TextStyle(
                  color: Color(0xFFD1005B),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.38,
                ),
              ),
            )
                : null),
      ],
    );
  }
}